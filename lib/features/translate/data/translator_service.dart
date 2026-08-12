import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'native/translate_ffi.dart';
import 'offline_translator.dart';
import 'tm_service.dart';

class TranslationResult {
  final String text;
  final String? detected;
  const TranslationResult({required this.text, this.detected});
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
    this.timeout = const Duration(seconds: 10),
    http.Client? client,
  }) : _client = client ?? http.Client();

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

  @override
  Future<TranslationResult> translate(
      String text, {
        required String from,
        required String to,
      }) async {
    final src = _nffi.normalize(text) ?? text.trim();
    if (src.isEmpty) return const TranslationResult(text: '');
    if (from == to && from != 'auto') return TranslationResult(text: src);

    // ═══ TM: мгновенный хит ПЕРЕД любым переводом ═══
    final tm = TmService.instance;
    if (tm.isAvailable && from != 'auto') {
      final hit = tm.lookup(src, from: from, to: to);
      if (hit != null) {
        debugPrint('[tm] hit score=${hit.score}');
        return TranslationResult(text: hit.dst, detected: null);
      }
    }

    if (src.length > 1800) return _translateChunked(src, from, to);
    return _translateSingle(src, from, to);
  }

  Future<TranslationResult> _translateChunked(
      String text,
      String from,
      String to,
      ) async {
    final chunks = _nffi.splitChunks(text, 1500) ?? _dartSplit(text, 1500);
    final sb = StringBuffer();
    String? detected;
    for (final ch in chunks) {
      final r = await _translateSingle(ch, from, to);
      detected ??= r.detected;
      if (sb.isNotEmpty) sb.writeln();
      sb.write(r.text);
    }
    return TranslationResult(text: sb.toString(), detected: detected);
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

  Future<TranslationResult> _translateSingle(
      String src,
      String from,
      String to,
      ) async {
    // 0) Оффлайн (ML Kit)
    try {
      final off = await OfflineTranslator.instance
          .translate(src, from: from, to: to)
          .timeout(timeout);
      if (off != null && off.text.isNotEmpty) return off;
    } catch (_) {}

    final errors = <String>[];

    // 1) Google
    try {
      final r = await _googleGtx(src, from, to).timeout(timeout);
      if (r.text.isNotEmpty) return r;
    } catch (e) {
      errors.add('google:$e');
    }

    // 2) Lingva
    for (final host in _lingvaHosts) {
      try {
        final r = await _lingva(host, src, from, to).timeout(timeout);
        if (r.text.isNotEmpty) return r;
      } catch (e) {
        errors.add('lingva($host):$e');
      }
    }

    // 3) MyMemory
    try {
      final srcLang = from == 'auto' ? _detectLang(src, to) : from;
      final r = await _myMemory(src, srcLang, to).timeout(timeout);
      if (r.text.isNotEmpty) {
        return TranslationResult(
          text: r.text,
          detected: from == 'auto' ? srcLang : null,
        );
      }
    } catch (e) {
      errors.add('mymemory:$e');
    }

    throw const TranslationFailedException(
      'Terjime başa barmady. Interneti barlaň.',
    );
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
        _ => target == 'en' ? 'ru' : 'en',
      };
    }
    if (text.runes.any((r) => r >= 0x0400 && r <= 0x04FF)) return 'ru';
    if (RegExp(r'[äçžňöşüýÄÇŽŇÖŞÜÝ]').hasMatch(text)) return 'tk';
    if (text.runes.any((r) => r >= 0x0600 && r <= 0x06FF)) return 'ar';
    if (text.runes.any((r) => r >= 0x4E00 && r <= 0x9FFF)) return 'zh';
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