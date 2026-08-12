import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _RebuildN = Int32 Function(
    Int32,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>);
typedef _RebuildD = int Function(
    int,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>,
    Pointer<Pointer<Utf8>>);

typedef _AddN = Int32 Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef _AddD = int Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

typedef _LookupN = Int32 Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, Int32);
typedef _LookupD = int Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Uint8>, int);

typedef _ClearN = Int32 Function();
typedef _ClearD = int Function();

class TmNative {
  static final TmNative instance = TmNative._();

  late final _RebuildD _rebuild;
  late final _AddD _add;
  late final _LookupD _lookup;
  late final _ClearD _clear;

  bool _ok = false;
  bool get available => _ok;

  // 4 МБ буфер для результата — хватит на любой перевод
  late final Pointer<Uint8> _lookupBuf = calloc<Uint8>(4 * 1024 * 1024);

  int get lookupBufSize => 4 * 1024 * 1024;
  Pointer<Uint8> get lookupBuf => _lookupBuf;

  TmNative._() {
    try {
      final lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();

      _rebuild = lib.lookupFunction<_RebuildN, _RebuildD>('pn_tm_rebuild');
      _add = lib.lookupFunction<_AddN, _AddD>('pn_tm_add');
      _lookup = lib.lookupFunction<_LookupN, _LookupD>('pn_tm_lookup');
      _clear = lib.lookupFunction<_ClearN, _ClearD>('pn_tm_clear');

      _ok = true;
      debugPrint('[tm] C++ engine loaded ✔');
    } catch (e) {
      _ok = false;
      debugPrint('[tm] C++ unavailable → Dart fallback: $e');
    }
  }

  int rebuild(int n, Pointer<Pointer<Utf8>> srcs, Pointer<Pointer<Utf8>> dsts,
      Pointer<Pointer<Utf8>> froms, Pointer<Pointer<Utf8>> tos) =>
      _rebuild(n, srcs, dsts, froms, tos);

  int add(Pointer<Utf8> src, Pointer<Utf8> dst, Pointer<Utf8> from,
      Pointer<Utf8> to) =>
      _add(src, dst, from, to);

  int lookup(Pointer<Utf8> src, Pointer<Utf8> from, Pointer<Utf8> to,
      Pointer<Uint8> out, int outSz) =>
      _lookup(src, from, to, out, outSz);

  int clear() => _clear();
}