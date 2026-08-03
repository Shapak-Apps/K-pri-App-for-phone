import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/controllers/app_settings_controller.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  // глобальные значения, синхронизируются с настройками из main.dart
  static double _gRate = 0.5, _gVolume = 1.0, _gPitch = 1.0;

  static void applySettings(AppSettingsController s) {
    _gRate = s.speechRate;
    _gVolume = s.ttsVolume;
    _gPitch = s.ttsPitch;
  }

  Future<void> init() async {
    if (_ready) return;
    await _tts.setVolume(_gVolume);
    await _tts.setPitch(_gPitch);
    _ready = true;
  }

  Future<void> speak(
    String text,
    String langCode, {
    double? rate,
    double? volume,
    double? pitch,
  }) async {
    if (text.trim().isEmpty) return;
    if (!_ready) await init();
    await _tts.setLanguage(await _bestLocale(langCode));
    await _tts.setSpeechRate((rate ?? _gRate).clamp(0.1, 1.0));
    await _tts.setVolume((volume ?? _gVolume).clamp(0.0, 1.0));
    await _tts.setPitch((pitch ?? _gPitch).clamp(0.5, 2.0));
    await _tts.speak(text);
  }

  Future<String> _bestLocale(String code) async {
    final candidates = _candidatesFor(code);
    for (final loc in candidates) {
      try {
        if (await _tts.isLanguageAvailable(loc) == true) return loc;
      } catch (_) {}
    }
    return candidates.last;
  }

  List<String> _candidatesFor(String code) {
    switch (code) {
      case 'tk':
        return ['tk-TM', 'tr-TR', 'en-US'];
      case 'ru':
        return ['ru-RU', 'en-US'];
      case 'en':
        return ['en-US', 'en-GB'];
      default:
        return ['${code}_${code.toUpperCase()}', 'en-US'];
    }
  }

  Future<void> stop() => _tts.stop();
}
