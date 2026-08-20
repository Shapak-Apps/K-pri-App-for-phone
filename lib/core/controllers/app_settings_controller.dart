import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_strings.dart';

enum PhraseSpeakMode { iface, english, both }

class AppSettingsController extends ChangeNotifier {
  static const _boxName = 'settings';
  late final Box _box;

  ThemeMode _themeMode = ThemeMode.dark;
  AppLang _lang = AppLang.tk;
  double _fontScale = 1.0;

  double _speechRate = 0.5;
  double _ttsVolume = 1.0;
  double _ttsPitch = 1.0;
  bool _autoSpeak = false;
  int _listenSeconds = 45;
  int _pauseSeconds = 2;

  String _defaultFrom = 'auto';
  String _defaultTo = 'ru';
  bool _autoTranslate = true;
  int _translateDelayMs = 700;

  PhraseSpeakMode _phraseSpeak = PhraseSpeakMode.both;
  int _flashcardSession = 20;
  bool _spacedRep = true;

  bool _autoSaveHistory = true;
  int _autoCleanDays = 0;

  int _accentIndex = 0;
  bool _animationsOn = true;
  bool _compact = false;

  ThemeMode get themeMode => _themeMode;
  AppLang get lang => _lang;
  AppLocalizations get l10n => AppLocalizations(_lang);
  double get fontScale => _fontScale;
  double get speechRate => _speechRate;
  double get ttsVolume => _ttsVolume;
  double get ttsPitch => _ttsPitch;
  bool get autoSpeak => _autoSpeak;
  int get listenSeconds => _listenSeconds;
  int get pauseSeconds => _pauseSeconds;
  String get defaultFrom => _defaultFrom;
  String get defaultTo => _defaultTo;
  bool get autoTranslate => _autoTranslate;
  int get translateDelayMs => _translateDelayMs;
  PhraseSpeakMode get phraseSpeak => _phraseSpeak;
  int get flashcardSession => _flashcardSession;
  bool get spacedRep => _spacedRep;
  bool get autoSaveHistory => _autoSaveHistory;
  int get autoCleanDays => _autoCleanDays;
  int get accentIndex => _accentIndex;
  bool get animationsOn => _animationsOn;
  bool get compact => _compact;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _themeMode = ThemeMode
        .values[_box.get('theme', defaultValue: ThemeMode.dark.index) as int];
    _lang =
    AppLang.values[_box.get('lang', defaultValue: AppLang.tk.index) as int];
    _fontScale = (_box.get('fontScale', defaultValue: 0.85) as num).toDouble();
    _speechRate = (_box.get('speechRate', defaultValue: 0.5) as num).toDouble();
    _ttsVolume = (_box.get('ttsVolume', defaultValue: 1.0) as num).toDouble();
    _ttsPitch = (_box.get('ttsPitch', defaultValue: 1.0) as num).toDouble();
    _autoSpeak = _box.get('autoSpeak', defaultValue: false) as bool;
    _listenSeconds = _box.get('listenSeconds', defaultValue: 45) as int;
    _pauseSeconds = _box.get('pauseSeconds', defaultValue: 2) as int;
    _defaultFrom = _box.get('defaultFrom', defaultValue: 'auto') as String;
    _defaultTo = _box.get('defaultTo', defaultValue: 'ru') as String;
    _autoTranslate = _box.get('autoTranslate', defaultValue: true) as bool;
    _translateDelayMs = _box.get('translateDelayMs', defaultValue: 700) as int;
    _phraseSpeak =
    PhraseSpeakMode.values[_box.get(
      'phraseSpeak',
      defaultValue: PhraseSpeakMode.both.index,
    )
    as int];
    _flashcardSession = _box.get('flashcardSession', defaultValue: 20) as int;
    _spacedRep = _box.get('spacedRep', defaultValue: true) as bool;
    _autoSaveHistory = _box.get('autoSaveHistory', defaultValue: true) as bool;
    _autoCleanDays = _box.get('autoCleanDays', defaultValue: 0) as int;
    _accentIndex = _box.get('accentIndex', defaultValue: 0) as int;
    _animationsOn = _box.get('animationsOn', defaultValue: true) as bool;
    _compact = _box.get('compact', defaultValue: false) as bool;
  }

  Future<void> put(String k, dynamic v) async {
    await _box.put(k, v);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode m) async {
    _themeMode = m;
    await _box.put('theme', m.index);
    notifyListeners();
  }

  Future<void> setLang(AppLang l) async {
    _lang = l;
    await _box.put('lang', l.index);
    notifyListeners();
  }

  Future<void> setFontScale(double v) async {
    _fontScale = v;
    await _box.put('fontScale', v);
    notifyListeners();
  }

  Future<void> setSpeechRate(double v) async {
    _speechRate = v;
    await _box.put('speechRate', v);
    notifyListeners();
  }

  Future<void> setTtsVolume(double v) async {
    _ttsVolume = v;
    await _box.put('ttsVolume', v);
    notifyListeners();
  }

  Future<void> setTtsPitch(double v) async {
    _ttsPitch = v;
    await _box.put('ttsPitch', v);
    notifyListeners();
  }

  Future<void> setAutoSpeak(bool v) async {
    _autoSpeak = v;
    await _box.put('autoSpeak', v);
    notifyListeners();
  }

  Future<void> setListenSeconds(int v) async {
    _listenSeconds = v;
    await _box.put('listenSeconds', v);
    notifyListeners();
  }

  Future<void> setPauseSeconds(int v) async {
    _pauseSeconds = v;
    await _box.put('pauseSeconds', v);
    notifyListeners();
  }

  Future<void> setDefaultFrom(String v) async {
    _defaultFrom = v;
    await _box.put('defaultFrom', v);
    notifyListeners();
  }

  Future<void> setDefaultTo(String v) async {
    _defaultTo = v;
    await _box.put('defaultTo', v);
    notifyListeners();
  }

  Future<void> setAutoTranslate(bool v) async {
    _autoTranslate = v;
    await _box.put('autoTranslate', v);
    notifyListeners();
  }

  Future<void> setTranslateDelayMs(int v) async {
    _translateDelayMs = v;
    await _box.put('translateDelayMs', v);
    notifyListeners();
  }

  Future<void> setPhraseSpeak(PhraseSpeakMode v) async {
    _phraseSpeak = v;
    await _box.put('phraseSpeak', v.index);
    notifyListeners();
  }

  Future<void> setFlashcardSession(int v) async {
    _flashcardSession = v;
    await _box.put('flashcardSession', v);
    notifyListeners();
  }

  Future<void> setSpacedRep(bool v) async {
    _spacedRep = v;
    await _box.put('spacedRep', v);
    notifyListeners();
  }

  Future<void> setAutoSaveHistory(bool v) async {
    _autoSaveHistory = v;
    await _box.put('autoSaveHistory', v);
    notifyListeners();
  }

  Future<void> setAutoCleanDays(int v) async {
    _autoCleanDays = v;
    await _box.put('autoCleanDays', v);
    notifyListeners();
  }

  Future<void> setAccentIndex(int v) async {
    _accentIndex = v;
    await _box.put('accentIndex', v);
    notifyListeners();
  }

  Future<void> setAnimationsOn(bool v) async {
    _animationsOn = v;
    await _box.put('animationsOn', v);
    notifyListeners();
  }

  Future<void> setCompact(bool v) async {
    _compact = v;
    await _box.put('compact', v);
    notifyListeners();
  }
}

class AppProviders extends InheritedNotifier<AppSettingsController> {
  const AppProviders({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<AppProviders>();
    assert(w != null, 'AppProviders not found above this widget.');
    return w!.notifier!;
  }
}

extension SettingsX on BuildContext {
  AppSettingsController get settings => AppProviders.of(this);
  AppLocalizations get l10n => AppProviders.of(this).l10n;
}