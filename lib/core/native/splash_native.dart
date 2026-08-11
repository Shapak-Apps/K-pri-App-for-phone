import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _InitN = Void Function();
typedef _InitD = void Function();

typedef _PartN = Int32 Function(Double, Int32, Pointer<Float>, Int32);
typedef _PartD = int Function(double, int, Pointer<Float>, int);

typedef _StrkN = Int32 Function(Double, Double, Int32, Pointer<Float>, Int32);
typedef _StrkD = int Function(double, double, int, Pointer<Float>, int);

typedef _LetN = Int32 Function(Double, Double, Int32, Pointer<Float>, Int32);
typedef _LetD = int Function(double, double, int, Pointer<Float>, int);

class SplashNative {
  static final SplashNative instance = SplashNative._();

  late final _InitD _init;
  late final _PartD _particles;
  late final _StrkD _streaks;
  late final _LetD _letters;

  bool _ok = false;
  bool get available => _ok;

  // ── нативные буферы ──
  final Pointer<Float> particleBuf = calloc<Float>(16 * 5);
  final Pointer<Float> streakBuf = calloc<Float>(96 * 5);
  final Pointer<Float> letterBuf = calloc<Float>(8 * 4);

  late final Float32List particleList = particleBuf.asTypedList(16 * 5);
  late final Float32List streakList = streakBuf.asTypedList(96 * 5);
  late final Float32List letterList = letterBuf.asTypedList(8 * 4);

  SplashNative._() {
    try {
      final lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();

      _init = lib.lookupFunction<_InitN, _InitD>('sp_init');
      _particles = lib.lookupFunction<_PartN, _PartD>('sp_particles');
      _streaks = lib.lookupFunction<_StrkN, _StrkD>('sp_streaks');
      _letters = lib.lookupFunction<_LetN, _LetD>('sp_letters');

      _init();
      _ok = true;
      debugPrint('[splash] C++ engine loaded ✔');
    } catch (e) {
      _ok = false;
      debugPrint('[splash] C++ unavailable → Dart fallback: $e');
    }
  }

  int particles(double t, int count) =>
      _particles(t, count, particleBuf, 16);

  int streaks(double time, double intensity, int count) =>
      _streaks(time, intensity, count, streakBuf, 96);

  int letters(double mainT, double wavePhase, int count) =>
      _letters(mainT, wavePhase, count, letterBuf, 8);
}