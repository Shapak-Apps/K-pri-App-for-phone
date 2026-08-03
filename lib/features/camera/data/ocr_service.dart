import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OcrService {
  static const _assetDir = 'assets/tessdata/';

  static const _families = <List<String>>[
    [
      'eng',
      'tur',
      'deu',
      'fra',
      'spa',
      'ita',
      'por',
      'nld',
      'pol',
      'vie',
      'ind',
      'aze',
      'uzb_latn',
      'tuk',
      'cat',
      'hun',
      'ron',
      'ces',
      'swe',
      'dan',
      'nor',
      'fin',
      'msa',
      'tgl',
      'swa',
      'afr',
      'sqi',
      'eus',
      'glg',
    ],
    [
      'rus',
      'ukr',
      'bel',
      'bul',
      'srp',
      'mkd',
      'kaz',
      'uzb_cyrl',
      'kir',
      'tgk',
      'mon',
    ],
    ['ara', 'fas', 'urd', 'heb', 'pus'],
    ['chi_sim', 'chi_tra', 'jpn', 'kor'],
    [
      'hin',
      'tha',
      'tam',
      'tel',
      'ben',
      'nep',
      'pan',
      'guj',
      'mar',
      'kan',
      'mal',
      'sin',
      'khm',
      'lao',
      'mya',
    ],
  ];

  Set<String>? _available;

  Future<Set<String>> _loadAvailable() async {
    if (_available != null) return _available!;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final keys = manifest.listAssets().toSet();
    final all = <String>{for (final f in _families) ...f};
    _available = {
      for (final code in all)
        if (keys.contains('$_assetDir$code.traineddata')) code,
    };
    debugPrint('[ocr] available models: $_available');
    return _available!;
  }

  Future<String> recognize(String path) async {
    try {
      final available = await _loadAvailable();
      if (available.isEmpty) {
        debugPrint('[ocr] no traineddata in $_assetDir');
        return '';
      }

      var best = '';
      for (final family in _families) {
        final used = family.where(available.contains).toList();
        if (used.isEmpty) continue;
        final lang = used.join('+');
        final text = await _run(path, lang);
        final t = text.trim();
        if (t.length > best.length) best = t;
      }
      return best;
    } catch (e) {
      debugPrint('[ocr] recognize error: $e');
      return '';
    }
  }

  Future<String> _run(String path, String lang) async {
    try {
      // ПРАВИЛЬНАЯ сигнатура: путь — первый аргумент (String),
      // язык — через language: (НЕ через args["lang"]!).
      final text = await FlutterTesseractOcr.extractText(
        path,
        language: lang, // 'eng+rus+…' из семейства
        args: {
          "psm": "3", // авто-сегментация страницы (для фото/вывесок)
          "preserve_interword_spaces": "1",
        },
      );
      return text;
    } catch (e) {
      debugPrint('[ocr] run($lang) error: $e');
      return '';
    }
  }
}
