import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _LoadN = Int32 Function(
    Int32, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>);
typedef _LoadD = int Function(
    int, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>, Pointer<Pointer<Utf8>>);

typedef _TrN = Int32 Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, Int32, Pointer<Int32>);
typedef _TrD = int Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, int, Pointer<Int32>);

class MtNative {
  static final MtNative instance = MtNative._();

  late final _LoadD _load;
  late final _TrD _tr;
  bool _ok = false;
  bool get available => _ok;

  MtNative._() {
    try {
      final lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();
      _load = lib.lookupFunction<_LoadN, _LoadD>('pn_mt_load');
      _tr = lib.lookupFunction<_TrN, _TrD>('pn_mt_translate');
      _ok = true;
      debugPrint('[mt] C++ engine loaded ✔');
    } catch (e) {
      _ok = false;
      debugPrint('[mt] C++ unavailable: $e');
    }
  }

  int load(int n, Pointer<Pointer<Utf8>> ru, Pointer<Pointer<Utf8>> en,
      Pointer<Pointer<Utf8>> tk, Pointer<Pointer<Utf8>> tr) =>
      _load(n, ru, en, tk, tr);

  int translate(Pointer<Utf8> text, Pointer<Utf8> from, Pointer<Uint8> out,
      int outSz, Pointer<Int32> quality) =>
      _tr(text, from, out, outSz, quality);
}