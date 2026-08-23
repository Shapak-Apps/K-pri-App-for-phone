import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechResultCb = void Function(String words, bool isFinal);
typedef SpeechLevelCb = void Function(double level);
typedef SpeechEndCb = void Function();
typedef SpeechErrorCb = void Function(String message);

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;
  bool _wantListening = false;
  bool _engineBusy = false;
  bool _stopRequested = false;

  SpeechResultCb? _onResult;
  SpeechLevelCb? _onLevel;
  SpeechEndCb? _onEnd;
  SpeechErrorCb? _onError;

  String _locale = 'en_US';
  Duration _listenFor = const Duration(seconds: 55);
  Duration _pauseFor = const Duration(seconds: 5);

  DateTime _sessionStart = DateTime.now();
  DateTime _lastResultTime = DateTime.now();
  bool _gotResult = false;
  bool _restartScheduled = false;
  int _netFails = 0;
  int _restartAttempts = 0;
  double _peakLevel = 0.0;

  Completer<bool>? _initCompleter;
  Timer? _silenceTimer;

  static const _restartDelay = Duration(milliseconds: 500);
  static const _netRestartBaseDelay = Duration(milliseconds: 800);
  static const _maxNetFails = 3;
  static const _maxRestarts = 5;
  static const _silenceTimeout = Duration(seconds: 8);

  bool get isReady => _ready;
  bool get isListening => _wantListening;

  Future<bool> init() async {
    if (_ready) return true;

    final existing = _initCompleter;
    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<bool>();
    _initCompleter = completer;

    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final req = await Permission.microphone.request();
        if (!req.isGranted) {
          debugPrint('[speech] microphone permission denied');
          completer.complete(false);
          return false;
        }
      }

      _ready = await _stt
          .initialize(onError: _handleError, onStatus: _handleStatus)
          .timeout(const Duration(seconds: 8), onTimeout: () => false);

      completer.complete(_ready);
      return _ready;
    } catch (e) {
      debugPrint('[speech] init error: $e');
      completer.complete(false);
      return false;
    } finally {
      _initCompleter = null;
    }
  }

  Future<void> start({
    required String appLangCode,
    required SpeechResultCb onResult,
    SpeechLevelCb? onLevel,
    SpeechEndCb? onEnd,
    SpeechErrorCb? onError,
    Duration listenFor = const Duration(seconds: 55),
    Duration pauseFor = const Duration(seconds: 5),
  }) async {
    _onResult = onResult;
    _onLevel = onLevel;
    _onEnd = onEnd;
    _onError = onError;
    _listenFor = listenFor;
    _pauseFor = pauseFor;
    _locale = localeFor(appLangCode);
    _wantListening = true;
    _stopRequested = false;
    _netFails = 0;
    _restartAttempts = 0;
    _peakLevel = 0.0;

    if (!_ready) {
      final ok = await init();
      if (!ok) {
        _wantListening = false;
        onError?.call('not_ready');
        return;
      }
    }
    await _startEngine();
  }

  Future<void> _startEngine() async {
    if (!_wantListening || _engineBusy) return;

    if (_restartAttempts >= _maxRestarts) {
      _finish('max_restarts');
      return;
    }

    _engineBusy = true;
    try {
      if (_stt.isListening) {
        try {
          await _stt.stop().timeout(const Duration(milliseconds: 300));
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 120));
      }
    } catch (_) {}

    _gotResult = false;
    _sessionStart = DateTime.now();
    _lastResultTime = DateTime.now();
    debugPrint(
      '[speech] engine start locale=$_locale attempt=${_restartAttempts + 1}',
    );

    try {
      await _stt
          .listen(
            onResult: (r) {
              _lastResultTime = DateTime.now();
              debugPrint(
                '[speech] result final=${r.finalResult} "${r.recognizedWords}"',
              );
              _gotResult = true;
              _netFails = 0;
              _restartAttempts = 0;
              _onResult?.call(r.recognizedWords, r.finalResult);
            },
            onSoundLevelChange: (lvl) {
              if (lvl > _peakLevel) _peakLevel = lvl;
              _onLevel?.call(lvl);
            },
            localeId: _locale,
            listenFor: _listenFor,
            pauseFor: _pauseFor,
            partialResults: true,
            listenMode: ListenMode.confirmation,
            cancelOnError: false,
            sampleRate: 16000,
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('listen timeout');
            },
          );

      debugPrint('[speech] listen() ok');
      _startSilenceTimer();
    } catch (e) {
      debugPrint('[speech] listen() threw: $e');
      _netFails++;
      if (_netFails >= _maxNetFails) {
        _finish('listen_failed');
      } else {
        _scheduleRestart(_exponentialDelay());
      }
    } finally {
      _engineBusy = false;
    }
  }

  Duration _exponentialDelay() {
    final base = _netRestartBaseDelay.inMilliseconds;
    final exp = base * (1 << _restartAttempts.clamp(0, 4));
    final jitter = (DateTime.now().millisecondsSinceEpoch % 200);
    return Duration(milliseconds: exp + jitter);
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceTimeout, () {
      if (!_wantListening) return;
      final silence = DateTime.now().difference(_lastResultTime);
      if (silence >= _silenceTimeout && !_gotResult) {
        debugPrint('[speech] silence timeout — auto stop');
        _finish('silence_timeout');
      } else if (silence >= _silenceTimeout && _gotResult) {
        _finish('idle');
      }
    });
  }

  void _handleStatus(String s) {
    debugPrint('[speech] status: $s');

    if (s == 'listening') {
      _engineBusy = false;
      return;
    }

    if (s != 'done' && s != 'notListening') return;

    if (!_wantListening || _stopRequested) {
      _silenceTimer?.cancel();
      _onEnd?.call();
      return;
    }

    _restartAttempts++;
    _scheduleRestart(_restartDelay);
  }

  void _handleError(SpeechRecognitionError e) {
    final msg = e.errorMsg;
    debugPrint('[speech] error: $msg (permanent=${e.permanent})');

    if (!_wantListening) {
      _onError?.call(msg);
      return;
    }

    final hard =
        e.permanent ||
        RegExp(
          r'permission|denied|not_available|not initialized|no recognizer|audio',
          caseSensitive: false,
        ).hasMatch(msg);

    if (hard) {
      _finish(msg);
      return;
    }

    if (!_gotResult) _netFails++;
    if (_netFails >= _maxNetFails) {
      _finish('network_unstable');
    } else {
      _scheduleRestart(_exponentialDelay());
    }
  }

  void _finish(String msg) {
    final duration = DateTime.now().difference(_sessionStart).inSeconds;
    debugPrint(
      '[speech] finish: $msg (session: ${duration}s, peak_level: ${_peakLevel.toStringAsFixed(1)}, results: $_gotResult)',
    );

    _silenceTimer?.cancel();
    _wantListening = false;
    _stopRequested = true;
    _restartScheduled = false;
    _engineBusy = false;
    _netFails = 0;
    _restartAttempts = 0;

    if (!_gotResult && _peakLevel < 5.0 && msg != 'silence_timeout') {
      _onError?.call('low_audio');
    } else {
      _onError?.call(msg);
    }
  }

  void _scheduleRestart(Duration delay) {
    if (_restartScheduled || !_wantListening || _stopRequested) return;
    _restartScheduled = true;
    Future.delayed(delay, () {
      _restartScheduled = false;
      if (_wantListening && !_stopRequested) _startEngine();
    });
  }

  Future<void> stop() async {
    debugPrint('[speech] stop');
    _wantListening = false;
    _stopRequested = true;
    _restartScheduled = false;
    _silenceTimer?.cancel();
    try {
      if (_stt.isListening) {
        await _stt.stop().timeout(
          const Duration(milliseconds: 500),
          onTimeout: () => null,
        );
      }
    } catch (_) {}
  }

  Future<void> cancel() async {
    debugPrint('[speech] cancel');
    _wantListening = false;
    _stopRequested = true;
    _restartScheduled = false;
    _silenceTimer?.cancel();
    try {
      await _stt.cancel().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
    } catch (_) {}
  }

  String localeFor(String code) {
    const map = <String, String>{
      'ru': 'ru_RU',
      'en': 'en_US',
      'tr': 'tr_TR',
      'tk': 'ru_RU',
      'de': 'de_DE',
      'fr': 'fr_FR',
      'es': 'es_ES',
      'it': 'it_IT',
      'pt': 'pt_PT',
      'zh': 'zh_CN',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'ar': 'ar_SA',
      'uz': 'uz_UZ',
      'kk': 'kk_KZ',
      'uk': 'uk_UA',
      'pl': 'pl_PL',
      'nl': 'nl_NL',
      'sv': 'sv_SE',
      'no': 'no_NO',
      'da': 'da_DK',
      'fi': 'fi_FI',
      'cs': 'cs_CZ',
      'hu': 'hu_HU',
      'ro': 'ro_RO',
      'el': 'el_GR',
      'he': 'he_IL',
      'hi': 'hi_IN',
      'th': 'th_TH',
      'vi': 'vi_VN',
      'id': 'id_ID',
      'az': 'az_AZ',
      'ka': 'ka_GE',
      'hy': 'hy_AM',
    };

    if (code != 'auto') {
      return map[code] ?? '${code}_${code.toUpperCase()}';
    }
    final dev = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return map[dev] ?? 'en_US';
  }
}
