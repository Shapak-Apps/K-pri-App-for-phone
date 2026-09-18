import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/app/incoming_text.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../conversation/data/tts_service.dart';
import '../../history/data/history_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../data/speech_service.dart';
import '../data/translator_service.dart';
import 'translation_state.dart';

const bool kMicEnabled = false;
const String kMicComingSoonVersion = '2.0.0';

enum MicToggleOutcome { comingSoon, started, stopped, unavailable }

class TranslateController extends ChangeNotifier {
  TranslateController({
    required HistoryRepository repo,
    required AppSettingsController settings,
    required ValueListenable<IncomingText?> incomingText,
  }) : _repo = repo,
       _settings = settings,
       _incoming = incomingText {
    _from = _settings.defaultFrom;
    _to = _settings.defaultTo;

    _ctrl.addListener(_onInput);
    _incoming.addListener(_onIncomingText);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) _onIncomingText();
    });

    _speech.init();
    _tts.init();
  }

  final HistoryRepository _repo;
  final AppSettingsController _settings;
  final ValueListenable<IncomingText?> _incoming;

  final OnlineTranslator _service = OnlineTranslator();
  final SpeechService _speech = SpeechService();
  final TtsService _tts = TtsService();
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  static const Duration _idle = Duration(milliseconds: 2000);

  String _from = 'auto';
  String _to = 'ru';
  TranslationState _state = const IdleState();
  bool _disposed = false;
  bool _loading = false;
  bool _listening = false;
  bool _suppress = false;
  bool _voiceAnalyzing = false;
  bool _approx = false;
  Timer? _debounce;
  Timer? _idleT;
  String _base = '';

  String _recogBuffer = '';
  String _recogPartial = '';
  bool _awaitingRecog = false;
  Completer<String?>? _recogCompleter;

  int _lastIncomingId = -1;

  TextEditingController get ctrl => _ctrl;
  FocusNode get focus => _focus;
  String get from => _from;
  String get to => _to;
  TranslationState get state => _state;
  TranslationState get shownState =>
      _voiceAnalyzing ? const IdleState() : _state;
  bool get listening => _listening;
  bool get voiceAnalyzing => _voiceAnalyzing;
  bool get approx => _approx;
  bool get canTranslate => _ctrl.text.trim().isNotEmpty && !_voiceAnalyzing;
  String? get autoDetected => switch (_state) {
    SuccessState(detected: final d) when _from == 'auto' => d,
    _ => null,
  };

  @override
  void dispose() {
    _disposed = true;
    _incoming.removeListener(_onIncomingText);
    _debounce?.cancel();
    _idleT?.cancel();
    _speech.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onIncomingText() {
    if (_disposed) return;
    final ev = _incoming.value;
    if (ev == null) return;
    if (ev.id == _lastIncomingId) return;
    _lastIncomingId = ev.id;
    final text = ev.text.trim();
    if (text.isEmpty) return;

    _suppress = true;
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: text.length);
    _suppress = false;
    _state = const IdleState();
    notifyListeners();
    Future.microtask(translate);
  }

  void _onInput() {
    if (_suppress || _listening || _voiceAnalyzing) {
      _debounce?.cancel();
      _idleT?.cancel();
      return;
    }
    _debounce?.cancel();
    _idleT?.cancel();
    if (_ctrl.text.trim().isEmpty) {
      _state = const IdleState();
      notifyListeners();
      return;
    }
    if (!_settings.autoTranslate) return;
    _debounce = Timer(
      Duration(milliseconds: _settings.translateDelayMs),
      translate,
    );
    _idleT = Timer(_idle, () {
      if (_disposed) return;
      if (_focus.hasFocus) _focus.unfocus();
    });
  }

  Future<void> translate() async {
    if (_voiceAnalyzing) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      _state = const IdleState();
      notifyListeners();
      return;
    }
    if (_loading) return;
    _approx = false;
    _loading = true;
    _state = const LoadingState();
    notifyListeners();
    try {
      final res = await _service.translate(text, from: _from, to: _to);
      if (_disposed) return;
      final saved = _from == 'auto' ? (res.detected ?? 'auto') : _from;
      _loading = false;
      _approx = res.approx;
      _state = SuccessState(res.text, res.detected);
      notifyListeners();
      if (_settings.autoSaveHistory) {
        _repo.add(source: text, result: res.text, from: saved, to: _to);
      }
      ProfileRepository.instance.onTranslationDone();
      try {
        await HomeWidget.saveWidgetData<String>('last_source', text);
        await HomeWidget.saveWidgetData<String>('last_result', res.text);
        await HomeWidget.saveWidgetData<String>('last_pair', '$saved → $_to');
        await HomeWidget.updateWidget(
          name: 'KopriWidgetProvider',
          androidName: 'KopriWidgetProvider',
        );
      } catch (e) {
        debugPrint('[widget] update error: $e');
      }
      if (_settings.autoSpeak) {
        _tts.speak(res.text, _to);
      }
    } catch (e) {
      debugPrint('[translate] error: $e');
      if (_disposed) return;
      _loading = false;
      _state = ErrorState(_settings.l10n.t('translate_error'));
      notifyListeners();
    }
  }

  String _voiceText() {
    final b = _recogBuffer.trim();
    final p = _recogPartial.trim();
    if (b.isEmpty) return p;
    if (p.isEmpty) return b;
    return '$b $p';
  }

  void _resetRecog() {
    _recogBuffer = '';
    _recogPartial = '';
    _awaitingRecog = false;
    _recogCompleter = null;
  }

  Future<String?> _waitRecognition(Duration timeout) async {
    final now = _voiceText();
    if (now.isNotEmpty) return now;
    _awaitingRecog = true;
    _recogCompleter = Completer<String?>();
    final res = await _recogCompleter!.future.timeout(
      timeout,
      onTimeout: () => null,
    );
    _awaitingRecog = false;
    _recogCompleter = null;
    return res;
  }

  Future<void> _finalizeVoice() async {
    var text = _voiceText();
    if (text.isEmpty) {
      text = (await _waitRecognition(const Duration(seconds: 3))) ?? '';
    }
    if (_disposed) return;

    final combined = _base.isEmpty
        ? text
        : (text.isEmpty ? _base : '$_base $text');

    if (text.isEmpty) {
      _voiceAnalyzing = false;
      notifyListeners();
      return;
    }

    try {
      final res = await _service.translate(text, from: _from, to: _to);
      if (_disposed) return;
      final saved = _from == 'auto' ? (res.detected ?? 'auto') : _from;
      _suppress = true;
      _ctrl.text = combined;
      _ctrl.selection = TextSelection.collapsed(offset: combined.length);
      _suppress = false;
      _voiceAnalyzing = false;
      _approx = res.approx;
      _state = SuccessState(res.text, res.detected);
      notifyListeners();
      if (_settings.autoSaveHistory) {
        _repo.add(source: combined, result: res.text, from: saved, to: _to);
      }
      ProfileRepository.instance.onTranslationDone();
      if (_settings.autoSpeak) {
        _tts.speak(res.text, _to);
      }
    } catch (e) {
      debugPrint('[voice-translate] error: $e');
      if (_disposed) return;
      _suppress = true;
      _ctrl.text = combined;
      _ctrl.selection = TextSelection.collapsed(offset: combined.length);
      _suppress = false;
      _voiceAnalyzing = false;
      notifyListeners();
    }
  }

  Future<MicToggleOutcome> toggleMic() async {
    if (!kMicEnabled) return MicToggleOutcome.comingSoon;

    if (_listening) {
      _listening = false;
      _voiceAnalyzing = true;
      notifyListeners();
      await _speech.stop();
      _finalizeVoice();
      return MicToggleOutcome.stopped;
    }

    final ok = await _speech.init();
    if (!ok || _disposed) return MicToggleOutcome.unavailable;

    if (_focus.hasFocus) _focus.unfocus();
    _base = _ctrl.text.trim();
    _resetRecog();
    _listening = true;
    _voiceAnalyzing = false;
    notifyListeners();

    await _speech.start(
      appLangCode: _from,
      onError: (msg) {
        debugPrint('[mic] error: $msg');
        if (_disposed) return;
        if (_awaitingRecog &&
            _recogCompleter != null &&
            !_recogCompleter!.isCompleted) {
          _recogCompleter!.complete(null);
        }
        _listening = false;
        _voiceAnalyzing = false;
        notifyListeners();
      },
      onResult: (w, isFinal) {
        if (_disposed) return;
        final t = w.trim();

        if (_voiceAnalyzing) {
          if (t.isEmpty) return;
          if (isFinal) {
            _recogBuffer = _recogBuffer.isEmpty ? t : '$_recogBuffer $t';
            _recogPartial = '';
          } else {
            _recogPartial = t;
          }
          if (_awaitingRecog &&
              _recogCompleter != null &&
              !_recogCompleter!.isCompleted) {
            _recogCompleter!.complete(_voiceText());
          }
          return;
        }

        if (!_listening || t.isEmpty) return;
        if (isFinal) {
          _recogBuffer = _recogBuffer.isEmpty ? t : '$_recogBuffer $t';
          _recogPartial = '';
        } else {
          _recogPartial = t;
        }
      },
    );
    return MicToggleOutcome.started;
  }

  void setFrom(String v) {
    _from = v;
    notifyListeners();
    translate();
  }

  void setTo(String v) {
    _to = v;
    notifyListeners();
    translate();
  }

  void swap() {
    final t = _from;
    _from = _to;
    _to = t;
    if (_state case SuccessState(:final text)) {
      _ctrl.text = text;
      _ctrl.selection = TextSelection.collapsed(offset: text.length);
      _state = const IdleState();
    }
    notifyListeners();
  }

  void clearInput() {
    _ctrl.clear();
    _state = const IdleState();
    notifyListeners();
  }

  void unfocus() {
    if (_focus.hasFocus) _focus.unfocus();
  }

  void speak() {
    if (_state case SuccessState(:final text)) {
      if (text.isNotEmpty) {
        _tts.speak(text, _to, rate: _settings.speechRate);
      }
    }
  }
}
