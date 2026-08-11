import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class OcrService {
  static const _assetDir = 'assets/tessdata/';
  static const _goodScore = 0.7;

  static const _maxRuns = 16;

  static const _families = <(String, List<String>)>[
    ('mix', ['rus', 'eng']),
    ('cyr', ['rus', 'ukr', 'bel']),
    ('cyr', ['kaz', 'uzb_cyrl', 'kir', 'tgk', 'mon', 'bul', 'srp', 'mkd']),
    ('ara', ['ara', 'fas', 'urd', 'heb', 'pus']),
    ('cjk', ['chi_sim', 'chi_tra', 'jpn', 'kor']),
    ('dev', ['hin', 'tha', 'tam', 'tel', 'ben', 'nep', 'pan', 'guj', 'mar', 'kan', 'mal', 'sin', 'khm', 'lao', 'mya']),
    ('lat', ['eng', 'tur', 'deu', 'fra', 'spa', 'ita', 'por', 'aze', 'uzb_latn', 'tuk']),
  ];

  Set<String>? _available;
  TextRecognizer? _latin;

  Future<Set<String>> _loadAvailable() async {
    if (_available != null) return _available!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final keys = manifest.listAssets().toSet();
    final all = <String>{for (final f in _families) ...f.$2};
    _available = {
      for (final code in all)
        if (keys.contains('$_assetDir$code.traineddata')) code,
    };
    debugPrint('[ocr] available tessdata: $_available');
    return _available!;
  }

  Future<String> recognize(String path) async {
    var runs = 0;
    var globalBest = '';
    var globalScore = 0.0;

    final available = await _loadAvailable();
    final hasCyrillic = available.contains('rus');

    // ── 1) ML Kit — латиница ────────────────────────────────────
    var gmsOk = true;
    var latinSeen = false;
    try {
      _latin ??= TextRecognizer(script: TextRecognitionScript.latin);
      final res = await _latin!.processImage(InputImage.fromFile(File(path)));
      final t = res.text.trim();
      final s = _score(t, 'lat');

      if (s >= _goodScore && !hasCyrillic) {
        debugPrint('[ocr] ML Kit latin OK (no cyr tessdata): ${t.length} chars');
        return t;
      }
      if (s >= 0.25) latinSeen = true;
      if (t.isNotEmpty && s > globalScore) {
        globalScore = s;
        globalBest = t;
      }
    } catch (e) {
      gmsOk = false;
      debugPrint('[ocr] ML Kit unavailable: $e');
    }

    // ── 2) Tesseract с авто-поворотом ───────────────────────────
    if (available.isEmpty) return globalBest;

    final base = await _loadBase(path);
    if (base == null) return globalBest;

    final order = <(String, List<String>)>[..._families];

    if (gmsOk && !latinSeen) {
      order.removeWhere((f) => f.$1 == 'lat');
    }

    if (!gmsOk) {
      final lat = order.where((f) => f.$1 == 'lat').toList();
      order.removeWhere((f) => f.$1 == 'lat');
      final mixIdx = order.indexWhere((f) => f.$1 == 'mix');
      order.insertAll(mixIdx + 1, lat);
    }

    for (final fam in order) {
      if (runs >= _maxRuns) break;
      final used = fam.$2.where(available.contains).toList();
      if (used.isEmpty) continue;
      final lang = used.join('+');

      for (final angle in const [0, 90, 180, 270]) {
        if (runs >= _maxRuns) break;

        final image = angle == 0
            ? base
            : img.copyRotate(base, angle: angle, interpolation: img.Interpolation.linear);
        final tmp = await _tmpEncode(image);
        try {
          runs++;
          final text = (await _runTess(tmp, lang)).trim();
          final s = _score(text, fam.$1);
          debugPrint('[ocr] ${fam.$1}($lang) @${angle}° → score ${s.toStringAsFixed(2)}, ${text.length} chars');

          if (s > globalScore) {
            globalScore = s;
            globalBest = text;
          }
          if (s >= _goodScore) return text;

          if (angle == 0 && (text.isEmpty || s < 0.08)) break;
        } finally {
          try {
            await File(tmp).delete();
          } catch (_) {}
        }
      }
    }

    debugPrint('[ocr] done, best score ${globalScore.toStringAsFixed(2)}');
    return globalBest;
  }

  // ── Препроцессинг: КРУПНЕЕ + ровное освещение ────────────────
  Future<img.Image?> _loadBase(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;

      image = img.bakeOrientation(image);

      const target = 2600.0;
      const maxSide = 3200.0;
      final longest = image.width > image.height
          ? image.width.toDouble()
          : image.height.toDouble();

      if (longest < target) {
        final scale = (target / longest).clamp(1.0, 3.0);
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.cubic,
        );
      } else if (longest > maxSide) {
        final scale = maxSide / longest;
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.linear,
        );
      }

      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.35, brightness: 1.05);

      debugPrint('[ocr] base: ${image.width}x${image.height}');
      return image;
    } catch (e) {
      debugPrint('[ocr] loadBase error: $e');
      return null;
    }
  }

  Future<String> _tmpEncode(img.Image image) async {
    final dir = await getTemporaryDirectory();
    final p = '${dir.path}/ocr_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(p).writeAsBytes(img.encodeJpg(image, quality: 92));
    return p;
  }

  Future<String> _runTess(String path, String lang) async {
    try {
      return await FlutterTesseractOcr.extractText(
        path,
        language: lang,
        args: {
          'psm': '3',
          'preserve_interword_spaces': '1',
        },
      );
    } catch (e) {
      debugPrint('[ocr] tess($lang) error: $e');
      return '';
    }
  }

  double _score(String text, String script) {
    final t = text.trim();
    if (t.length < 3) return 0;

    var cyr = 0, lat = 0, ara = 0, cjk = 0, dev = 0;
    for (final r in t.runes) {
      if (r >= 0x0400 && r <= 0x04FF) {
        cyr++;
      } else if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) {
        lat++;
      } else if (r >= 0x0600 && r <= 0x06FF) {
        ara++;
      } else if ((r >= 0x4E00 && r <= 0x9FFF) ||
          (r >= 0x3040 && r <= 0x30FF) ||
          (r >= 0xAC00 && r <= 0xD7AF)) {
        cjk++;
      } else if (r >= 0x0900 && r <= 0x097F) {
        dev++;
      }
    }

    final letters = cyr + lat + ara + cjk + dev;
    if (letters < 3) return 0;

    final target = switch (script) {
      'mix' => cyr + lat,
      'cyr' => cyr,
      'lat' => lat,
      'ara' => ara,
      'cjk' => cjk,
      'dev' => dev,
      _ => letters,
    };

    final purity = target / letters;
    final density = letters / t.length;
    return purity * (density > 0.5 ? 1.0 : density / 0.5);
  }

  void dispose() {
    _latin?.close();
    _latin = null;
  }
}