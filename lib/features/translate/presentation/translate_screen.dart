import 'dart:async';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../conversation/data/tts_service.dart';
import '../../history/data/history_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../data/speech_service.dart';
import '../data/translator_service.dart';
import 'translation_state.dart';
import 'widgets/input_card.dart';
import 'widgets/language_selector.dart';
import 'widgets/result_card.dart';
import 'widgets/translate_bridge.dart';
import '../../../core/widgets/analyzing_wave.dart';
import 'package:flutter/foundation.dart';

class TranslateScreen extends StatefulWidget {
  final HistoryRepository repo;
  final ValueListenable<IncomingText?> incomingText;
  const TranslateScreen({
    super.key,
    required this.repo,
    required this.incomingText,
  });
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  static const _idle = Duration(milliseconds: 2000);
  final _service = OnlineTranslator();
  final _speech = SpeechService();
  final _tts = TtsService();
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  String _from = 'auto', _to = 'ru';
  bool _didInitLangs = false;
  TranslationState _state = const IdleState();
  bool _loading = false, _listening = false, _suppress = false;
  bool _voiceAnalyzing = false;
  Timer? _debounce, _idleT;
  String _base = '';

  String _recogBuffer = '';
  String _recogPartial = '';
  bool _awaitingRecog = false;
  Completer<String?>? _recogCompleter;

  int _lastIncomingId = -1;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onInput);
    _speech.init();
    _tts.init();
    widget.incomingText.addListener(_onIncomingText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
      _onIncomingText();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitLangs) {
      _didInitLangs = true;
      _from = context.settings.defaultFrom;
      _to = context.settings.defaultTo;
    }
  }

  @override
  void dispose() {
    widget.incomingText.removeListener(_onIncomingText);
    _debounce?.cancel();
    _idleT?.cancel();
    _speech.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onIncomingText() {
    final ev = widget.incomingText.value;
    if (ev == null) return;
    if (ev.id == _lastIncomingId) return;
    _lastIncomingId = ev.id;
    final text = ev.text.trim();
    if (text.isEmpty) return;

    _suppress = true;
    _ctrl.text = text;
    _ctrl.selection = TextSelection.collapsed(offset: text.length);
    _suppress = false;
    setState(() => _state = const IdleState());
    Future.microtask(_translate);
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

  void _onInput() {
    if (_suppress || _listening || _voiceAnalyzing) {
      _debounce?.cancel();
      _idleT?.cancel();
      return;
    }
    _debounce?.cancel();
    _idleT?.cancel();
    if (_ctrl.text.trim().isEmpty) {
      setState(() => _state = const IdleState());
      return;
    }
    if (!context.settings.autoTranslate) return;
    _debounce = Timer(
      Duration(milliseconds: context.settings.translateDelayMs),
      _translate,
    );
    _idleT = Timer(_idle, () {
      if (mounted && _focus.hasFocus) _focus.unfocus();
    });
  }

  Future<void> _translate() async {
    if (_voiceAnalyzing) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _state = const IdleState());
      return;
    }
    if (_loading) return;
    setState(() {
      _loading = true;
      _state = const LoadingState();
    });
    try {
      final res = await _service.translate(text, from: _from, to: _to);
      if (!mounted) return;
      final saved = _from == 'auto' ? (res.detected ?? 'auto') : _from;
      setState(() {
        _loading = false;
        _state = SuccessState(res.text, res.detected);
      });
      if (context.settings.autoSaveHistory) {
        widget.repo.add(source: text, result: res.text, from: saved, to: _to);
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
      if (context.settings.autoSpeak) {
        _tts.speak(res.text, _to);
      }
    } catch (e) {
      debugPrint('[translate] error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _state = ErrorState(context.l10n.t('translate_error'));
      });
    }
  }

  Future<void> _finalizeVoice() async {
    var text = _voiceText();
    if (text.isEmpty) {
      text = (await _waitRecognition(const Duration(seconds: 3))) ?? '';
    }
    if (!mounted) return;

    final combined = _base.isEmpty
        ? text
        : (text.isEmpty ? _base : '$_base $text');

    if (text.isEmpty) {
      setState(() => _voiceAnalyzing = false);
      return;
    }

    try {
      final res = await _service.translate(text, from: _from, to: _to);
      if (!mounted) return;
      final saved = _from == 'auto' ? (res.detected ?? 'auto') : _from;
      _suppress = true;
      _ctrl.text = combined;
      _ctrl.selection = TextSelection.collapsed(offset: combined.length);
      _suppress = false;
      setState(() {
        _voiceAnalyzing = false;
        _state = SuccessState(res.text, res.detected);
      });
      if (context.settings.autoSaveHistory) {
        widget.repo.add(
          source: combined,
          result: res.text,
          from: saved,
          to: _to,
        );
      }
      ProfileRepository.instance.onTranslationDone();
      if (context.settings.autoSpeak) {
        _tts.speak(res.text, _to);
      }
    } catch (e) {
      debugPrint('[voice-translate] error: $e');
      if (!mounted) return;
      _suppress = true;
      _ctrl.text = combined;
      _ctrl.selection = TextSelection.collapsed(offset: combined.length);
      _suppress = false;
      setState(() => _voiceAnalyzing = false);
    }
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      setState(() {
        _listening = false;
        _voiceAnalyzing = true;
      });
      await _speech.stop();
      _finalizeVoice();
      return;
    }

    final ok = await _speech.init();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mikrofon / ses tanamak elýeterli däl'),
          backgroundColor: context.c.warn,
        ),
      );
      return;
    }

    if (_focus.hasFocus) _focus.unfocus();
    _base = _ctrl.text.trim();
    _resetRecog();
    setState(() {
      _listening = true;
      _voiceAnalyzing = false;
    });

    await _speech.start(
      appLangCode: _from,
      onError: (msg) {
        debugPrint('[mic] error: $msg');
        if (!mounted) return;
        if (_awaitingRecog &&
            _recogCompleter != null &&
            !_recogCompleter!.isCompleted) {
          _recogCompleter!.complete(null);
        }
        setState(() {
          _listening = false;
          _voiceAnalyzing = false;
        });
      },
      onResult: (w, isFinal) {
        if (!mounted) return;
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
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
      if (_state case SuccessState(:final text)) {
        _ctrl.text = text;
        _ctrl.selection = TextSelection.collapsed(offset: text.length);
        _state = const IdleState();
      }
    });
  }

  void _speak() {
    if (_state case SuccessState(:final text)) {
      if (text.isNotEmpty)
        _tts.speak(text, _to, rate: context.settings.speechRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auto = switch (_state) {
      SuccessState(detected: final d) when _from == 'auto' => d,
      _ => null,
    };
    final can = _ctrl.text.trim().isNotEmpty && !_voiceAnalyzing;
    final shownState = _voiceAnalyzing ? const IdleState() : _state;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_focus.hasFocus) _focus.unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LanguageSelector(
            from: _from,
            to: _to,
            onFromChanged: (v) {
              setState(() => _from = v);
              _translate();
            },
            onToChanged: (v) {
              setState(() => _to = v);
              _translate();
            },
            onSwap: _swap,
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                InputCard(
                  controller: _ctrl,
                  focusNode: _focus,
                  onSubmitted: (_) {
                    if (_focus.hasFocus) _focus.unfocus();
                  },
                  autoDetected: auto,
                  onClear: () {
                    _ctrl.clear();
                    setState(() => _state = const IdleState());
                  },
                  isListening: _listening,
                  onMicTap: _toggleMic,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _voiceAnalyzing
                      ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: AnalyzingWave(
                      label: context.l10n.t('analyzing'),
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 14),
                TranslateBridge(
                  state: shownState,
                  canTranslate: can,
                  onTap: _translate,
                ),
                const SizedBox(height: 14),
                ResultCard(state: shownState, onSpeak: _speak),
              ],
            ),
          ),
        ],
      ),
    );
  }
}