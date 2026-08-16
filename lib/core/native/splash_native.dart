import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _InitC = Void Function();
typedef _ParticlesC = Int32 Function(Double, Int32, Pointer<Float>, Int32);
typedef _StreaksC = Int32 Function(Double, Double, Int32, Pointer<Float>, Int32);
typedef _LettersC = Int32 Function(Double, Double, Int32, Pointer<Float>, Int32);

typedef _InitD = void Function();
typedef _ParticlesD = int Function(double, int, Pointer<Float>, int);
typedef _StreaksD = int Function(double, double, int, Pointer<Float>, int);
typedef _LettersD = int Function(double, double, int, Pointer<Float>, int);

class SplashNative {
  static final SplashNative instance = SplashNative._();

  late final _InitD _init;
  late final _ParticlesD _particles;
  late final _StreaksD _streaks;
  late final _LettersD _letters;

  bool _isAvailable = false;
  bool get available => _isAvailable;

  static const int _particleCap = 16;
  static const int _streakCap = 96;
  static const int _letterCap = 8;

  static const int _particleStride = 5;
  static const int _streakStride = 5;
  static const int _letterStride = 4;

  late final Pointer<Float> _particleBuf;
  late final Pointer<Float> _streakBuf;
  late final Pointer<Float> _letterBuf;
  late final Float32List particleList;
  late final Float32List streakList;
  late final Float32List letterList;

  SplashNative._() {
    if (kIsWeb) {
      _isAvailable = false;
      return;
    }

    try {
      final DynamicLibrary lib;

      if (Platform.isAndroid) {
        lib = DynamicLibrary.open('libprofile_native.so');
      } else if (Platform.isIOS) {
        lib = DynamicLibrary.process();
      } else if (Platform.isMacOS) {
        lib = DynamicLibrary.open('libprofile_native.dylib');
      } else if (Platform.isWindows) {
        lib = DynamicLibrary.open('profile_native.dll');
      } else if (Platform.isLinux) {
        lib = DynamicLibrary.open('libprofile_native.so');
      } else {
        lib = DynamicLibrary.process();
      }

      _init = lib.lookupFunction<_InitC, _InitD>('sp_init');
      _particles = lib.lookupFunction<_ParticlesC, _ParticlesD>('sp_particles');
      _streaks = lib.lookupFunction<_StreaksC, _StreaksD>('sp_streaks');
      _letters = lib.lookupFunction<_LettersC, _LettersD>('sp_letters');

      _particleBuf = calloc<Float>(_particleCap * _particleStride);
      _streakBuf = calloc<Float>(_streakCap * _streakStride);
      _letterBuf = calloc<Float>(_letterCap * _letterStride);

      particleList = _particleBuf.asTypedList(_particleCap * _particleStride);
      streakList = _streakBuf.asTypedList(_streakCap * _streakStride);
      letterList = _letterBuf.asTypedList(_letterCap * _letterStride);

      _init();
      _isAvailable = true;

      if (kDebugMode) {
        debugPrint('[SplashNative] 🚀 C++ engine loaded successfully.');
      }
    } catch (e, stackTrace) {
      _isAvailable = false;
      if (kDebugMode) {
        debugPrint('[SplashNative] ⚠️ C++ unavailable → Fallback to Dart math.\n$e');
      }
    }
  }

  int particles(double t, int count) {
    if (!_isAvailable) return 0;
    return _particles(t, count, _particleBuf, _particleCap);
  }

  int streaks(double time, double intensity, int count) {
    if (!_isAvailable) return 0;
    return _streaks(time, intensity, count, _streakBuf, _streakCap);
  }

  int letters(double mainT, double wavePhase, int count) {
    if (!_isAvailable) return 0;
    return _letters(mainT, wavePhase, count, _letterBuf, _letterCap);
  }

  void dispose() {
    if (_isAvailable) {
      calloc.free(_particleBuf);
      calloc.free(_streakBuf);
      calloc.free(_letterBuf);
      _isAvailable = false;
    }
  }
}