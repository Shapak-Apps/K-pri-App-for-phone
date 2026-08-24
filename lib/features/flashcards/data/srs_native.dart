import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

class SrsReviewResult {
  final int reps;
  final double ef;
  final int interval;
  final int dueMs;
  const SrsReviewResult({
    required this.reps,
    required this.ef,
    required this.interval,
    required this.dueMs,
  });
}

typedef _ReviewN =
    Int32 Function(
      Int32,
      Double,
      Int32,
      Int32,
      Int64,
      Pointer<Int32>,
      Pointer<Double>,
      Pointer<Int32>,
      Pointer<Int64>,
    );
typedef _ReviewD =
    int Function(
      int,
      double,
      int,
      int,
      int,
      Pointer<Int32>,
      Pointer<Double>,
      Pointer<Int32>,
      Pointer<Int64>,
    );

typedef _DueN =
    Int32 Function(Pointer<Int64>, Int32, Int64, Int32, Pointer<Int32>, Int32);
typedef _DueD =
    int Function(Pointer<Int64>, int, int, int, Pointer<Int32>, int);

class SrsNative {
  static final SrsNative instance = SrsNative._();
  bool _ok = false;
  bool get available => _ok;

  late final _ReviewD _review;
  late final _DueD _due;

  SrsNative._() {
    try {
      final lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();
      _review = lib.lookupFunction<_ReviewN, _ReviewD>('srs_review');
      _due = lib.lookupFunction<_DueN, _DueD>('srs_due_indices');
      _ok = true;
      debugPrint('[srs] C++ engine loaded ✔');
    } catch (e) {
      _ok = false;
      debugPrint('[srs] C++ unavailable → Dart fallback: $e');
    }
  }

  SrsReviewResult? review({
    required int reps,
    required double ef,
    required int interval,
    required int quality,
    required int nowMs,
  }) {
    if (!_ok) return null;
    final pReps = calloc<Int32>();
    final pEf = calloc<Double>();
    final pInt = calloc<Int32>();
    final pDue = calloc<Int64>();
    try {
      final r = _review(
        reps,
        ef,
        interval,
        quality,
        nowMs,
        pReps,
        pEf,
        pInt,
        pDue,
      );
      if (r != 0) return null;
      return SrsReviewResult(
        reps: pReps.value,
        ef: pEf.value,
        interval: pInt.value,
        dueMs: pDue.value,
      );
    } catch (_) {
      return null;
    } finally {
      calloc.free(pReps);
      calloc.free(pEf);
      calloc.free(pInt);
      calloc.free(pDue);
    }
  }

  List<int>? dueIndices(List<int> dueMs, int nowMs, int limit) {
    if (!_ok || dueMs.isEmpty || limit <= 0) return null;
    final pIn = calloc<Int64>(dueMs.length);
    final pOut = calloc<Int32>(limit);
    try {
      for (var i = 0; i < dueMs.length; i++) pIn[i] = dueMs[i];
      final count = _due(pIn, dueMs.length, nowMs, limit, pOut, limit);
      if (count <= 0) return [];
      return [for (var i = 0; i < count; i++) pOut[i]];
    } catch (_) {
      return null;
    } finally {
      calloc.free(pIn);
      calloc.free(pOut);
    }
  }
}
