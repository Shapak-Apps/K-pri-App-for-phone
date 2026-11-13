import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/native/apk_channel.dart';
import 'translator_service.dart';

class OfflineTranslator extends ChangeNotifier {
  OfflineTranslator._();
  static final OfflineTranslator instance = OfflineTranslator._();

  final _models = OnDeviceTranslatorModelManager();
  final _langId = LanguageIdentifier(confidenceThreshold: 0.5);

  /// One translator for each language pair, the last used one at the end.
  /// ML Kit loads the models when a translator is used the first time, and
  /// right after the app starts this can take more than a second. So the
  /// translator is kept and used again.
  final _translators = <(String, String), OnDeviceTranslator>{};

  /// Each translator keeps its models in memory, so only a few are kept.
  static const _maxTranslators = 3;

  String? downloadingCode;
  String? failedCode;

  /// The "Download models" setting. main.dart connects it to the settings.
  ModelDownload Function() downloadMode = () => ModelDownload.wifiOnly;

  static const Set<String> supported = {
    'af', 'sq', 'ar', 'be', 'bn', 'bg', 'ca', 'zh', 'hr', 'cs',
    'da', 'nl', 'en', 'et', 'fi', 'fr', 'gl', 'de', 'el', 'gu',
    'he', 'hi', 'hu', 'is', 'id', 'ga', 'it', 'ja', 'kn', 'ko',
    'lv', 'lt', 'mk', 'ms', 'mt', 'mr', 'no', 'fa', 'pl', 'pt',
    'ro', 'ru', 'sk', 'sl', 'es', 'sw', 'sv', 'ta', 'te', 'th',
    'tr', 'uk', 'ur', 'vi', 'cy',
  };

  static final _tkChars = RegExp(r'[äçžňöşüýÄÇŽŇÖŞÜÝ]');

  bool _supported(String code) => supported.contains(code);

  Future<String?> detect(String text) async {
    try {
      final langs = await _langId.identifyPossibleLanguages(text);
      if (langs.isEmpty) return null;
      final top = langs.first;
      if (top.languageTag == 'und' || top.confidence < 0.6) return null;
      return top.languageTag;
    } catch (e) {
      debugPrint('[offline] detect error: $e');
      return null;
    }
  }

  /// Whether the "Download models" setting allows a download now. ML Kit's
  /// own `isWifiRequired: true` is not used: on mobile data its download
  /// waits for Wi-Fi and does not end, and the banner would stay.
  Future<bool> _mayDownload() async {
    switch (downloadMode()) {
      case ModelDownload.never:
        return false;
      case ModelDownload.wifiAndMobile:
        return true;
      case ModelDownload.wifiOnly:
        // The check is in MainActivity, so only on Android.
        if (defaultTargetPlatform != TargetPlatform.android) return true;
        try {
          final metered = await kApkChannel.invokeMethod<bool>(
            'isNetworkMetered',
          );
          return metered == false;
        } catch (e) {
          debugPrint('[offline] network check failed: $e');
          return false;
        }
    }
  }

  Future<bool> _ensureModels(String from, String to) async {
    if (failedCode != null) {
      failedCode = null;
      notifyListeners();
    }

    var changed = false;
    String? current;
    try {
      for (final code in [from, to]) {
        current = code;
        if (await _models.isModelDownloaded(code)) {
          debugPrint('[offline] model already present: $code');
          continue;
        }

        if (!await _mayDownload()) {
          debugPrint(
            '[offline] not downloading $code: setting ${downloadMode().name}',
          );
          if (changed) notifyListeners();
          return false;
        }

        downloadingCode = code;
        notifyListeners();
        debugPrint('[offline] downloading model: $code');

        await _models.downloadModel(code, isWifiRequired: false);

        downloadingCode = null;
        notifyListeners();

        final ok = await _models.isModelDownloaded(code);
        if (!ok) {
          failedCode = code;
          notifyListeners();
          debugPrint('[offline] model NOT downloaded after task: $code');
          return false;
        }
        changed = true;
        debugPrint('[offline] model downloaded: $code');
      }
      if (changed) notifyListeners();
      return true;
    } catch (e, st) {
      downloadingCode = null;
      failedCode = current;
      notifyListeners();
      debugPrint('[offline] ensureModels error: $e');
      debugPrint('[offline] stack: $st');
      return false;
    }
  }

  Future<List<String>> downloadedModels() async {
    try {
      final results = await Future.wait(
        supported.map((code) async {
          final ok = await _models.isModelDownloaded(code);
          return ok ? code : null;
        }),
      );
      return results.whereType<String>().toList()..sort();
    } catch (e) {
      debugPrint('[offline] downloadedModels error: $e');
      return const [];
    }
  }

  Future<bool> deleteModel(String code) async {
    _closeTranslators((pair) => pair.$1 == code || pair.$2 == code);
    try {
      await _models.deleteModel(code);
      final stillThere = await _models.isModelDownloaded(code);
      if (stillThere) {
        debugPrint(
          '[offline] deleteModel($code) -> still present (system pack?)',
        );
        return false;
      }
      debugPrint('[offline] model deleted: $code');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[offline] deleteModel($code) error: $e');
      return false;
    }
  }

  Future<int> deleteAllDownloaded() async {
    final codes = await downloadedModels();
    var n = 0;
    for (final code in codes) {
      if (await deleteModel(code)) n++;
    }
    debugPrint('[offline] deleteAll: removed $n of ${codes.length}');
    return n;
  }

  /// Translates on the phone, or returns null. If a model still has to be
  /// downloaded, it waits for the download at most [downloadWait] (the
  /// download goes on after that). If the models are on the phone, it waits
  /// for the translation.
  Future<TranslationResult?> translate(
      String text, {
        required String from,
        required String to,
        Duration? downloadWait,
      }) async {
    var src = from;
    String? detected;

    if (from == 'auto') {
      if (_tkChars.hasMatch(text)) return null;
      detected = await detect(text);
      if (detected == null || !_supported(detected)) return null;
      src = detected;
    }

    if (!_supported(src) || !_supported(to)) return null;
    if (src == to) return TranslationResult(text: text, detected: detected);

    final onPhone =
        await _models.isModelDownloaded(src) &&
        await _models.isModelDownloaded(to);
    var models = _ensureModels(src, to);
    if (!onPhone && downloadWait != null) {
      models = models.timeout(downloadWait, onTimeout: () => false);
    }
    if (!await models) return null;

    final translator = _translatorFor(src, to);
    try {
      final out = (await translator.translateText(text)).trim();
      if (out.isEmpty) return null;
      return TranslationResult(text: out, detected: detected);
    } catch (e) {
      debugPrint('[offline] translate error: $e');
      // Do not keep a broken translator: the next call makes a new one.
      _closeTranslators((pair) => pair == (src, to));
      return null;
    }
  }

  OnDeviceTranslator _translatorFor(String from, String to) {
    final pair = (from, to);
    final translator =
        _translators.remove(pair) ??
        OnDeviceTranslator(
          sourceLanguage: _lang(from),
          targetLanguage: _lang(to),
        );
    _translators[pair] = translator; // the last used one at the end
    if (_translators.length > _maxTranslators) {
      final oldest = _translators.keys.first;
      _closeTranslators((p) => p == oldest);
    }
    return translator;
  }

  void _closeTranslators(bool Function((String, String) pair) test) {
    _translators.removeWhere((pair, translator) {
      if (!test(pair)) return false;
      unawaited(translator.close());
      return true;
    });
  }

  TranslateLanguage _lang(String code) => TranslateLanguage.values.firstWhere(
        (l) => l.bcpCode == code,
    orElse: () => TranslateLanguage.english,
  );

  @override
  void dispose() {
    _closeTranslators((_) => true);
    _langId.close();
    super.dispose();
  }
}