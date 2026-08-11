import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef _StrN = Int32 Function(Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef _StrD = int Function(Pointer<Utf8>, Pointer<Uint8>, int);
typedef _SplitN = Int32 Function(Pointer<Utf8>, Int32, Pointer<Uint8>, Int32);
typedef _SplitD = int Function(Pointer<Utf8>, int, Pointer<Uint8>, int);
typedef _GtxN = Int32 Function(
    Pointer<Utf8>, Pointer<Uint8>, Int32, Pointer<Uint8>, Int32);
typedef _GtxD = int Function(Pointer<Utf8>, Pointer<Uint8>, int, Pointer<Uint8>, int);

class TranslateFFI {
  static final TranslateFFI _i = TranslateFFI._();
  factory TranslateFFI() => _i;

  TranslateFFI._() {
    try {
      _lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();
      _detect = _lib.lookupFunction<_StrN, _StrD>('pn_detect_script');
      _norm = _lib.lookupFunction<_StrN, _StrD>('pn_normalize');
      _flag = _lib.lookupFunction<_StrN, _StrD>('pn_flag_emoji');
      _split = _lib.lookupFunction<_SplitN, _SplitD>('pn_split_chunks');
      _gtx = _lib.lookupFunction<_GtxN, _GtxD>('pn_parse_gtx');
      _native = true;
    } catch (e) {
      _native = false;
    }
  }

  late final DynamicLibrary _lib;
  late final _StrD _detect, _norm, _flag;
  late final _SplitD _split;
  late final _GtxD _gtx;
  bool _native = false;
  bool get isAvailable => _native;

  String? _callStr(String input, _StrD Function() getter, int buf) {
    if (!_native) return null;
    try {
      final fn = getter();
      final inp = input.toNativeUtf8();
      final out = calloc<Uint8>(buf);
      try {
        if (fn(inp, out, buf) < 0) return null;
        return out.cast<Utf8>().toDartString();
      } finally {
        calloc.free(inp);
        calloc.free(out);
      }
    } catch (_) {
      _native = false;
      return null;
    }
  }

  String? detectScript(String text) => _callStr(text, () => _detect, 32);

  String? normalize(String text) =>
      _callStr(text, () => _norm, text.length * 4 + 32);

  String? flag(String countryCode) => _callStr(countryCode, () => _flag, 32);

  List<String>? splitChunks(String text, int max) {
    if (!_native) return null;
    try {
      final inp = text.toNativeUtf8();
      final size = text.length * 2 + 1024;
      final out = calloc<Uint8>(size);
      try {
        if (_split(inp, max, out, size) < 0) return null;
        return out.cast<Utf8>().toDartString().split('\x1F');
      } finally {
        calloc.free(inp);
        calloc.free(out);
      }
    } catch (_) {
      _native = false;
      return null;
    }
  }

  ({String text, String? detected})? parseGtx(String json) {
    if (!_native) return null;
    try {
      final inp = json.toNativeUtf8();
      final txt = calloc<Uint8>(json.length * 4 + 64);
      final det = calloc<Uint8>(16);
      try {
        if (_gtx(inp, txt, json.length * 4 + 64, det, 16) < 0) return null;
        final d = det.cast<Utf8>().toDartString();
        return (
        text: txt.cast<Utf8>().toDartString(),
        detected: d.isEmpty ? null : d,
        );
      } finally {
        calloc.free(inp);
        calloc.free(txt);
        calloc.free(det);
      }
    } catch (_) {
      _native = false;
      return null;
    }
  }
}