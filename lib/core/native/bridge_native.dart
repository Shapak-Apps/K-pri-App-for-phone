import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

abstract final class BridgeLayout {
  static const cablePts = 40;
  static const hangers = 11;
  static const wavePts = 48;
  static const trail = 8;

  static const cable = 0;
  static const hangersOff = cablePts * 2;
  static const wave1 = hangersOff + hangers * 2;
  static const wave2 = wave1 + wavePts * 2;
  static const trailOff = wave2 + wavePts * 2;
  static const total = trailOff + trail * 2;

  static const deck = 0.66;
  static const top = 0.18;
  static const x1 = 0.30;
  static const x2 = 0.70;
}

class BridgeNative {
  static final BridgeNative instance = BridgeNative._();

  bool _ok = false;
  late final int Function(double, ffi.Pointer<ffi.Float>, int) _frame;
  ffi.Pointer<ffi.Float>? _buf;

  BridgeNative._() {
    try {
      final lib = Platform.isAndroid
          ? ffi.DynamicLibrary.open('libprofile_native.so')
          : ffi.DynamicLibrary.process();
      _frame = lib
          .lookupFunction<
            ffi.Int32 Function(ffi.Float, ffi.Pointer<ffi.Float>, ffi.Int32),
            int Function(double, ffi.Pointer<ffi.Float>, int)
          >('bridge_frame');
      _buf = calloc<ffi.Float>(BridgeLayout.total);
      _ok = true;
    } catch (_) {
      _ok = false;
    }
  }

  bool get available => _ok;

  void frame(double t, Float32List out) {
    final buf = _buf;
    if (_ok && buf != null) {
      final n = _frame(t, buf, BridgeLayout.total);
      if (n == BridgeLayout.total) {
        out.setRange(0, n, buf.asTypedList(n));
        return;
      }
    }
    _dartFallback(t, out);
  }

  static void _dartFallback(double t, Float32List out) {
    const deck = BridgeLayout.deck, top = BridgeLayout.top;
    const x1 = BridgeLayout.x1, x2 = BridgeLayout.x2;
    const water = 0.86, tau = 6.2831853;
    final sagY = 0.44 + 0.015 * math.sin(t * 2);

    double parab(double x) =>
        top + (sagY - top) * (1 - ((x - 0.5) / 0.2) * ((x - 0.5) / 0.2));
    double cableY(double x) {
      const end = deck - 0.02;
      if (x < x1) return end + (top - end) * ((x - 0.04) / (x1 - 0.04));
      if (x > x2) return top + (end - top) * ((x - x2) / (0.96 - x2));
      return parab(x);
    }

    var i = 0;
    for (var k = 0; k < BridgeLayout.cablePts; k++) {
      final x = 0.04 + 0.92 * (k / (BridgeLayout.cablePts - 1));
      out[i++] = x;
      out[i++] = cableY(x);
    }
    for (var k = 0; k < BridgeLayout.hangers; k++) {
      final x = x1 + (x2 - x1) * (k / (BridgeLayout.hangers - 1));
      out[i++] = x;
      out[i++] = parab(x);
    }
    for (var k = 0; k < BridgeLayout.wavePts; k++) {
      final x = k / (BridgeLayout.wavePts - 1);
      out[i++] = x;
      out[i++] = water + 0.012 * math.sin((x * 3 + t * 0.35) * tau);
    }
    for (var k = 0; k < BridgeLayout.wavePts; k++) {
      final x = k / (BridgeLayout.wavePts - 1);
      out[i++] = x;
      out[i++] =
          water + 0.02 + 0.008 * math.sin((x * 2.2 - t * 0.22 + 0.37) * tau);
    }
    final p = t * 0.45;
    final base = p - p.floor();
    for (var k = 0; k < BridgeLayout.trail; k++) {
      var q = base - k * 0.018;
      if (q < 0) q += 1;
      out[i++] = 0.06 + 0.88 * q;
      out[i++] = deck - 0.035;
    }
  }
}
