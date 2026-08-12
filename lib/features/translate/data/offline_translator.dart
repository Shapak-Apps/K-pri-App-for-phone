import 'package:flutter/foundation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'translator_service.dart';

class OfflineTranslator {
  OfflineTranslator._();
  static final OfflineTranslator instance = OfflineTranslator._();

  final _models = OnDeviceTranslatorModelManager();
  final _langId = LanguageIdentifier(confidenceThreshold: 0.5);

  static const Set<String> supported = {
    'af',
    'sq',
    'ar',
    'be',
    'bn',
    'bg',
    'ca',
    'zh',
    'hr',
    'cs',
    'da',
    'nl',
    'en',
    'et',
    'fi',
    'fr',
    'gl',
    'de',
    'el',
    'gu',
    'he',
    'hi',
    'hu',
    'is',
    'id',
    'ga',
    'it',
    'ja',
    'kn',
    'ko',
    'lv',
    'lt',
    'mk',
    'ms',
    'mt',
    'mr',
    'no',
    'fa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'es',
    'sw',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'cy',
  };

  static final _tkChars = RegExp(r'[äçžňöşüýÄÇŽŇÖŞÜÝ]');

  bool _supported(String code) => supported.contains(code);

  // ───────────────────────── ОПРЕДЕЛЕНИЕ ЯЗЫКА ─────────────────────────

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

  Future<bool> _ensureModels(String from, String to) async {
    try {
      for (final code in [from, to]) {
        if (await _models.isModelDownloaded(code)) {
          debugPrint('[offline] model already present: $code');
          continue;
        }
        debugPrint('[offline] downloading model: $code');
        final task = _models.downloadModel(code, isWifiRequired: false);
        await task;

        final ok = await _models.isModelDownloaded(code);
        if (!ok) {
          debugPrint('[offline] model NOT downloaded after task: $code');
          return false;
        }
        debugPrint('[offline] model downloaded: $code');
      }
      return true;
    } catch (e, st) {
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
      final codes = results.whereType<String>().toList()..sort();
      return codes;
    } catch (e) {
      debugPrint('[offline] downloadedModels error: $e');
      return const [];
    }
  }

  Future<bool> deleteModel(String code) async {
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

  Future<TranslationResult?> translate(
    String text, {
    required String from,
    required String to,
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
    if (!await _ensureModels(src, to)) return null;

    final translator = OnDeviceTranslator(
      sourceLanguage: _lang(src),
      targetLanguage: _lang(to),
    );
    try {
      final out = (await translator.translateText(text)).trim();
      if (out.isEmpty) return null;
      return TranslationResult(text: out, detected: detected);
    } catch (e) {
      debugPrint('[offline] translate error: $e');
      return null;
    } finally {
      await translator.close();
    }
  }

  TranslateLanguage _lang(String code) => TranslateLanguage.values.firstWhere(
    (l) => l.bcpCode == code,
    orElse: () => TranslateLanguage.english,
  );

  Future<void> dispose() => _langId.close();
}