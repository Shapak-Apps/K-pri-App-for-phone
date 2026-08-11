import 'dart:async';
import 'package:flutter/widgets.dart';
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

  SpeechResultCb? _onResult;
  SpeechLevelCb? _onLevel;
  SpeechEndCb? _onEnd;
  SpeechErrorCb? _onError;

  String _locale = 'en_US';
  Duration _listenFor = const Duration(seconds: 120);
  Duration _pauseFor = const Duration(seconds: 8);

  DateTime _sessionStart = DateTime.now();
  bool _gotResult = false;
  bool _restartScheduled = false;
  int _netFails = 0;

  Completer<bool>? _initCompleter;

  static const _restartDelay = Duration(milliseconds: 700);
  static const _netRestartDelay = Duration(milliseconds: 1500);
  static const _maxNetFails = 4;

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
      _ready = await _stt.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
      );
      completer.complete(_ready);
      return _ready;
    } catch (e) {
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
    Duration listenFor = const Duration(seconds: 120),
    Duration pauseFor = const Duration(seconds: 8),
  }) async {
    _onResult = onResult;
    _onLevel = onLevel;
    _onEnd = onEnd;
    _onError = onError;
    _listenFor = listenFor;
    _pauseFor = pauseFor;
    _locale = localeFor(appLangCode);
    _wantListening = true;
    _netFails = 0;

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
    if (!_wantListening) return;
    try {
      if (_stt.isListening) {
        await _stt.stop();
        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (_) {}

    _gotResult = false;
    _sessionStart = DateTime.now();
    debugPrint('[speech] engine start locale=$_locale');
    try {
      await _stt.listen(
        onResult: (r) {
          debugPrint(
            '[speech] result final=${r.finalResult} "${r.recognizedWords}"',
          );
          _gotResult = true;
          _netFails = 0;
          _onResult?.call(r.recognizedWords, r.finalResult);
        },
        onSoundLevelChange: (lvl) => _onLevel?.call(lvl),
        localeId: _locale,
        listenFor: _listenFor,
        pauseFor: _pauseFor,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
      );
      debugPrint('[speech] listen() ok');
    } catch (e) {
      debugPrint('[speech] listen() threw: $e');
      _netFails++;
      if (_netFails >= _maxNetFails) {
        _finish('listen_failed');
      } else {
        _scheduleRestart(_netRestartDelay);
      }
    }
  }

  void _handleStatus(String s) {
    debugPrint('[speech] status: $s');
    if (s != 'done' && s != 'notListening') return;

    if (!_wantListening) {
      _onEnd?.call();
      return;
    }
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
              r'permission|denied|not_available|not initialized|no recognizer',
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
      _scheduleRestart(_netRestartDelay);
    }
  }

  void _finish(String msg) {
    final duration = DateTime.now().difference(_sessionStart).inSeconds;
    debugPrint('[speech] finish: $msg (session lasted: ${duration}s)');

    _wantListening = false;
    _restartScheduled = false;
    _netFails = 0;
    _onError?.call(msg);
  }

  void _scheduleRestart(Duration delay) {
    if (_restartScheduled || !_wantListening) return;
    _restartScheduled = true;
    Future.delayed(delay, () {
      _restartScheduled = false;
      if (_wantListening) _startEngine();
    });
  }

  Future<void> stop() async {
    debugPrint('[speech] stop');
    _wantListening = false;
    _restartScheduled = false;
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> cancel() async {
    _wantListening = false;
    _restartScheduled = false;
    try {
      await _stt.cancel();
    } catch (_) {}
  }

  String localeFor(String code) {
    const map = <String, String>{
      'ru': 'ru_RU',
      'en': 'en_US',
      'tr': 'tr_TR',
      'tk': 'tk_TM',
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
    if (code != 'auto') return map[code] ?? '${code}_${code.toUpperCase()}';
    final dev = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return map[dev] ?? '${dev}_${dev.toUpperCase()}';
  }
}