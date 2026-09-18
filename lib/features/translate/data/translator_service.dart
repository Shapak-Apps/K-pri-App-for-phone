import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'mt_service.dart';
import 'native/translate_ffi.dart';
import 'offline_translator.dart';

class TranslationResult {
  final String text;
  final String? detected;
  final bool approx;
  final bool offline;
  const TranslationResult({
    required this.text,
    this.detected,
    this.approx = false,
    this.offline = false,
  });
}

class TranslationFailedException implements Exception {
  final String message;
  const TranslationFailedException(this.message);
  @override
  String toString() => message;
}

abstract interface class TranslatorService {
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  });
}

class OnlineTranslator implements TranslatorService {
  final Duration timeout;
  final http.Client _client;
  static final TranslateFFI _nffi = TranslateFFI();

  OnlineTranslator({
    this.timeout = const Duration(seconds: 7),
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Releases the underlying HTTP client (socket pool).
  /// Must be called by the owner (screen / controller) in `dispose()`,
  /// otherwise every opened page leaks its own socket pool.
  void close() => _client.close();

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    'Accept': 'application/json',
  };

  static const _lingvaHosts = [
    'lingva.thedaviddelta.com',
    'translate.plausibility.cloud',
    'lingva.lunar.icu',
  ];

  static const _tkOfflineSupported = {'ru', 'en', 'tr', 'tk'};

  @override
  Future<TranslationResult> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final src = _nffi.normalize(text) ?? text.trim();
    if (src.isEmpty) return const TranslationResult(text: '');
    if (from == to && from != 'auto')
      return TranslationResult(text: src, offline: true);

    String srcLang = from;
    if (from == 'auto') srcLang = _detectLang(src, to);

    if (srcLang == to) {
      return TranslationResult(text: src, detected: srcLang, offline: true);
    }

    if (_tkOfflineSupported.contains(srcLang) && _tkOfflineSupported.contains(to)) {
      final hit = MtService.instance.translate(src, srcLang, to: to);
      if (hit != null && hit.text.trim().isNotEmpty) {
        return TranslationResult(
          text: hit.text,
          detected: srcLang,
          approx: hit.quality >= 2,
          offline: true,
        );
      }
    }

    if (src.length > 1800) return _translateChunked(src, from, to);
    return _translateSingle(src, from, to);
  }

  bool _isHighQuality(
    String source,
    String translated,
    String from,
    String to,
  ) {
    if (translated.trim().isEmpty) return false;

    final srcWords = source
        .toLowerCase()
        .split(RegExp(r'[\s,.!?;:]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (srcWords.length <= 1) return true;

    final trWords = translated
        .toLowerCase()
        .split(RegExp(r'[\s,.!?;:]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    int untranslated = 0;
    for (final w in srcWords) {
      if (trWords.any((tw) => tw == w || _isSameScript(w, tw))) {
        untranslated++;
      }
    }

    final ratio = untranslated / srcWords.length;
    if (ratio > 0.25) return false;

    if (translated.length < source.length * 0.3) return false;

    return true;
  }

  bool _isSameScript(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    final aRunes = a.runes.toList();
    final bRunes = b.runes.toList();
    if (aRunes.isEmpty || bRunes.isEmpty) return false;
    final aCat = _scriptCat(aRunes.first);
    final bCat = _scriptCat(bRunes.first);
    return aCat == bCat && aCat != 'other';
  }

  String _scriptCat(int rune) {
    if (rune >= 0x0400 && rune <= 0x04FF) return 'cyr';
    if (rune >= 0x0041 && rune <= 0x024F) return 'lat';
    if (rune >= 0x0600 && rune <= 0x06FF) return 'ara';
    if (rune >= 0x4E00 && rune <= 0x9FFF) return 'cjk';
    return 'other';
  }

  Future<TranslationResult> _translateChunked(
    String text,
    String from,
    String to,
  ) async {
    final chunks = _nffi.splitChunks(text, 1500) ?? _dartSplit(text, 1500);
    final futures = chunks.map((ch) => _translateSingle(ch, from, to)).toList();
    final results = await Future.wait(futures, eagerError: true);

    final sb = StringBuffer();
    String? detected;
    bool anyApprox = false;
    for (final r in results) {
      detected ??= r.detected;
      anyApprox = anyApprox || r.approx;
      if (sb.isNotEmpty) sb.writeln();
      sb.write(r.text);
    }
    return TranslationResult(
      text: sb.toString(),
      detected: detected,
      approx: anyApprox,
    );
  }

  List<String> _dartSplit(String text, int max) {
    final out = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = start + max;
      if (end >= text.length) {
        end = text.length;
      } else {
        final cut = text.lastIndexOf('. ', end);
        end = cut > start + max ~/ 2 ? cut + 2 : end;
      }
      out.add(text.substring(start, end));
      start = end;
    }
    return out;
  }

  Future<TranslationResult> _raceTasks(
    List<Future<TranslationResult>> tasks,
  ) async {
    final completer = Completer<TranslationResult>();
    int pending = tasks.length;

    for (var task in tasks) {
      task
          .timeout(timeout)
          .then((res) {
            if (!completer.isCompleted && res.text.isNotEmpty) {
              completer.complete(res);
            }
          })
          .catchError((_) {})
          .whenComplete(() {
            pending--;
            if (pending == 0 && !completer.isCompleted) {
              completer.completeError(
                const TranslationFailedException(
                  'Terjime başa barmady. Interneti barlaň.',
                ),
              );
            }
          });
    }
    return completer.future;
  }

  Future<TranslationResult> _translateSingle(
    String src,
    String from,
    String to,
  ) async {
    try {
      final off = await OfflineTranslator.instance
          .translate(src, from: from, to: to)
          .timeout(const Duration(milliseconds: 800));
      if (off != null && off.text.isNotEmpty) return off;
    } catch (_) {}

    final srcLang = from == 'auto' ? _detectLang(src, to) : from;

    final tasks = <Future<TranslationResult>>[
      _googleGtx(src, from, to),
      _lingva(_lingvaHosts[0], src, from, to),
      _lingva(_lingvaHosts[1], src, from, to),
      _lingva(_lingvaHosts[2], src, from, to),
      _myMemory(src, srcLang, to),
    ];

    return _raceTasks(tasks);
  }

  String _detectLang(String text, String target) {
    final script = _nffi.detectScript(text);
    if (script != null) {
      return switch (script) {
        'cyr' => 'ru',
        'tk' => 'tk',
        'ara' => 'ar',
        'cjk' => 'zh',
        'dev' => 'hi',
        _ => _detectLatinLanguage(text, target),
      };
    }
    if (text.runes.any((r) => r >= 0x0400 && r <= 0x04FF)) return 'ru';
    if (RegExp(r'[äçžňöşüýÄÇŽŇÖŞÜÝ]').hasMatch(text)) return 'tk';
    if (text.runes.any((r) => r >= 0x0600 && r <= 0x06FF)) return 'ar';
    if (text.runes.any((r) => r >= 0x4E00 && r <= 0x9FFF)) return 'zh';
    return _detectLatinLanguage(text, target);
  }

  String _detectLatinLanguage(String text, String target) {
    final t = text.toLowerCase();

    final tkWords = {
      'we',
      'seniň',
      'meniň',
      'biziň',
      'siziň',
      'olaryň',
      'men',
      'sen',
      'ol',
      'biz',
      'siz',
      'olar',
      'nirede',
      'haçan',
      'näme',
      'kim',
      'nädip',
      'näçe',
      'haýsy',
      'salam',
      'sagbol',
      'sagboluň',
      'hawa',
      'ýok',
      'gowy',
      'erbet',
      'uly',
      'kiçi',
      'täze',
      'köne',
      'ýaş',
      'gary',
      'näme',
      'üçin',
      'sebäbi',
      'emma',
      'ýöne',
      'hem',
      'ýa',
      'diňe',
      'diýip',
      'diýdi',
      'barýaryn',
      'barýar',
      'geldim',
      'geldi',
      'gördüm',
      'gördi',
    };
    int tkCount = 0;
    for (final w in tkWords) {
      if (t.contains(RegExp('\\b$w\\b'))) tkCount++;
    }
    if (tkCount >= 2 || (tkCount == 1 && RegExp(r'[äžňüý]').hasMatch(text)))
      return 'tk';

    final trWords = {
      've',
      'bir',
      'bu',
      'şu',
      'için',
      'ile',
      'çok',
      'daha',
      'gibi',
      'ben',
      'sen',
      'biz',
      'siz',
      'onlar',
      'merhaba',
      'nasıl',
      'nerede',
      'ne',
      'kim',
      'nasılsın',
      'teşekkür',
      'evet',
      'hayır',
      'lütfen',
      'günaydın',
      'iyi',
      'kötü',
      'büyük',
      'küçük',
      'yeni',
      'eski',
      'güzel',
      'çirkin',
      'değil',
      'mı',
      'mi',
      'mu',
      'mü',
      'gidiyorum',
      'geliyorum',
      'yapıyorum',
    };
    int trCount = 0;
    for (final w in trWords) {
      if (t.contains(RegExp('\\b$w\\b'))) trCount++;
    }
    if (trCount >= 2) return 'tr';

    return target == 'en' ? 'ru' : 'en';
  }

  Future<TranslationResult> _googleGtx(
    String text,
    String from,
    String to,
  ) async {
    final uri = Uri.https('translate.googleapis.com', '/translate_a/single', {
      'client': 'gtx',
      'sl': from,
      'tl': to,
      'dt': 't',
      'q': text,
    });
    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';

    final native = _nffi.parseGtx(res.body);
    if (native != null && native.text.isNotEmpty) {
      return TranslationResult(
        text: native.text,
        detected: from == 'auto' ? native.detected : null,
      );
    }

    final decoded = jsonDecode(res.body) as List<dynamic>;
    final buf = StringBuffer();
    for (final chunk in decoded.first as List<dynamic>) {
      if (chunk is List<dynamic> && chunk.isNotEmpty && chunk.first is String) {
        buf.write(chunk.first as String);
      }
    }
    final detected =
        (from == 'auto' && decoded.length > 2 && decoded[2] is String)
        ? decoded[2] as String
        : null;
    final out = buf.toString().trim();
    if (out.isEmpty) throw 'empty';
    return TranslationResult(text: out, detected: detected);
  }

  Future<TranslationResult> _lingva(
    String host,
    String text,
    String from,
    String to,
  ) async {
    final uri = Uri.https(
      host,
      '/api/v1/$from/$to/${Uri.encodeComponent(text)}',
    );
    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final tr = (j['translation'] ?? '').toString().trim();
    final info = j['info'] as Map<String, dynamic>?;
    final detected =
        (from == 'auto' && info != null && info['detectedSource'] is String)
        ? info['detectedSource'] as String
        : null;
    if (tr.isEmpty) throw 'empty';
    return TranslationResult(text: tr, detected: detected);
  }

  Future<TranslationResult> _myMemory(
    String text,
    String from,
    String to,
  ) async {
    final uri = Uri.https('api.mymemory.translated.net', '/get', {
      'q': text,
      'langpair': '$from|$to',
    });
    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final data = j['responseData'] as Map<String, dynamic>?;
    final translated = (data?['translatedText'] ?? '').toString().trim();
    if (translated.isEmpty) throw 'empty';
    return TranslationResult(text: translated);
  }
}
