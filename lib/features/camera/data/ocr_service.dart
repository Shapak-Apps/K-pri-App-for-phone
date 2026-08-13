import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'ocr_native.dart';

class OcrService {
  static const _assetDir = 'assets/tessdata/';
  static const _goodScore = 0.72;
  static const _stopScore = 0.85;
  static const _maxRuns = 18;

  static const _families = <(String, List<String>)>[
    ('mix', ['rus', 'eng']),
    ('cyr', ['rus', 'ukr', 'bel']),
    ('cyr', ['kaz', 'uzb_cyrl', 'kir', 'tgk', 'mon', 'bul', 'srp', 'mkd']),
    ('ara', ['ara', 'fas', 'urd', 'heb', 'pus']),
    ('cjk', ['chi_sim', 'chi_tra', 'jpn', 'kor']),
    ('dev', [
      'hin', 'tha', 'tam', 'tel', 'ben',
      'nep', 'pan', 'guj', 'mar', 'kan',
      'mal', 'sin', 'khm', 'lao', 'mya',
    ]),
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
    final available = await _loadAvailable();
    final hasCyr = available.contains('rus');

    var mlText = '';
    var mlScore = 0.0;
    var gmsOk = false;
    if (!hasCyr) {
      try {
        _latin ??= TextRecognizer(script: TextRecognitionScript.latin);
        final res = await _latin!.processImage(InputImage.fromFile(File(path)));
        mlText = res.text.trim();
        mlScore = _score(mlText, 'lat');
        gmsOk = true;
        if (available.isEmpty) return mlText;
        if (mlScore >= _goodScore) return mlText;
      } catch (e) {
        debugPrint('[ocr] ML Kit unavailable: $e');
      }
    }

    final dir = await getTemporaryDirectory();
    final tag = DateTime.now().microsecondsSinceEpoch;
    final base = '${dir.path}/ocrb_$tag.png';
    final prepRes = await compute(ocrPrepWork, [path, base, 2200, 140]);
    if (prepRes != 0) {
      debugPrint('[ocr] C++ prep failed: $prepRes');
      return mlText;
    }
    debugPrint('[ocr] C++ prep OK');

    final temps = <String>[base];
    try {
      final scanLang = hasCyr
          ? (available.contains('eng') ? 'rus+eng' : 'rus')
          : (available.contains('eng') ? 'eng' : available.first);
      final scoreScript = hasCyr ? 'mix' : 'lat';

      var globalBest = '';
      var globalScore = -1.0;
      var globalLang = scanLang;
      var bestAngle = 0;
      var bestWork = base;

      for (final psm in const ['6', '11']) {
        if (runs >= _maxRuns) break;
        runs++;
        final text = (await _runTess(base, scanLang, psm)).trim();
        final s = _score(text, scoreScript);
        debugPrint('[ocr] 0° psm$psm → ${s.toStringAsFixed(2)}, ${text.length} chars');
        if (s > globalScore) {
          globalScore = s;
          globalBest = text;
          globalLang = scanLang;
        }
        if (s >= _goodScore) break;
      }

      if (globalScore < _goodScore) {
        for (final angle in const [90, 180, 270]) {
          if (runs >= _maxRuns || globalScore >= _stopScore) break;
          final img = '${dir.path}/ocrb_${tag}_r$angle.png';
          if (await compute(ocrRotateWork, [base, img, angle]) != 0) continue;
          temps.add(img);
          runs++;
          final text = (await _runTess(img, scanLang, '6')).trim();
          final s = _score(text, scoreScript);
          debugPrint('[ocr] angle $angle → ${s.toStringAsFixed(2)}, ${text.length} chars');
          if (s > globalScore) {
            globalScore = s;
            globalBest = text;
            bestAngle = angle;
            bestWork = img;
            globalLang = scanLang;
          }
          if (s >= _stopScore) break;
        }
      }

      final order = <(String, List<String>)>[..._families];
      if (gmsOk && mlScore >= 0.5) {
        order.removeWhere((f) => f.$1 == 'lat');
      }

      for (final fam in order) {
        if (runs >= _maxRuns || globalScore >= _stopScore) break;
        final used = fam.$2.where(available.contains).toList();
        if (used.isEmpty) continue;
        final lang = used.join('+');
        if (lang == globalLang) continue;
        runs++;
        final text = (await _runTess(bestWork, lang, '6')).trim();
        final s = _score(text, fam.$1);
        debugPrint('[ocr] ${fam.$1} @${bestAngle}° → ${s.toStringAsFixed(2)}, ${text.length} chars');
        if (s > globalScore) {
          globalScore = s;
          globalBest = text;
          globalLang = lang;
        }
      }

      if (globalScore < _goodScore && runs < _maxRuns) {
        runs++;
        final text = (await _runTess(bestWork, globalLang, '3')).trim();
        final s = _score(text, scoreScript);
        debugPrint('[ocr] psm3 fallback @${bestAngle}° → ${s.toStringAsFixed(2)}, ${text.length} chars');
        if (s > globalScore) {
          globalScore = s;
          globalBest = text;
        }
      }

      debugPrint('[ocr] done, best ${globalScore.toStringAsFixed(2)}');

      if (!hasCyr) {
        if (globalBest.trim().isEmpty && mlText.isNotEmpty) return mlText;
        if (globalScore < 0.3 && mlScore > globalScore && mlText.isNotEmpty) {
          return mlText;
        }
      }
      return globalBest;
    } finally {
      for (final t in temps) {
        try {
          await File(t).delete();
        } catch (_) {}
      }
    }
  }

  Future<String> _runTess(String path, String lang, String psm) async {
    try {
      return await FlutterTesseractOcr.extractText(
        path,
        language: lang,
        args: {
          'psm': psm,
          'preserve_interword_spaces': '1',
        },
      );
    } catch (e) {
      debugPrint('[ocr] tess($lang psm $psm) error: $e');
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
    final densityF = density > 0.5 ? 1.0 : density / 0.5;

    var pure = 0.0;
    for (final w in t.split(RegExp(r'\s+'))) {
      var wc = 0, wl = 0;
      for (final r in w.runes) {
        if (r >= 0x0400 && r <= 0x04FF) {
          wc++;
        } else if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) {
          wl++;
        }
      }
      final n = wc + wl;
      if (n == 0) continue;
      final dom = wc > wl ? wc : wl;
      pure += (dom / n >= 0.75) ? n : n * 0.25;
    }
    final consistency = letters > 0 ? (pure / letters).clamp(0.0, 1.0) : 1.0;

    var natural = 1.0;
    if ((script == 'cyr' || script == 'mix') && cyr > 0) {
      const common = 'еоаинстрвлкмдпуыьгзячйхб';
      var c = 0;
      for (final r in t.runes) {
        if (r >= 0x0400 && r <= 0x04FF &&
            common.contains(String.fromCharCode(r))) {
          c++;
        }
      }
      final ratio = c / cyr;
      natural = 0.6 + 0.4 * (ratio > 0.7 ? 1.0 : ratio / 0.7);
    }

    return purity * densityF * (0.5 + 0.5 * consistency) * natural;
  }

  void dispose() {
    _latin?.close();
    _latin = null;
  }
}