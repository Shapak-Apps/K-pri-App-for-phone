import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

typedef _PrepN = Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32, Int32);
typedef _PrepD = int Function(Pointer<Utf8>, Pointer<Utf8>, int, int);
typedef _RotN = Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Int32);
typedef _RotD = int Function(Pointer<Utf8>, Pointer<Utf8>, int);

int ocrPrepWork(List<Object> a) {
  if (!Platform.isAndroid) return -99;
  final lib = DynamicLibrary.open('libprofile_native.so');
  final prep = lib.lookupFunction<_PrepN, _PrepD>('pn_ocr_prep');
  final ps = (a[0] as String).toNativeUtf8();
  final pd = (a[1] as String).toNativeUtf8();
  try {
    return prep(ps, pd, a[2] as int, a[3] as int);
  } finally {
    calloc.free(ps);
    calloc.free(pd);
  }
}

int ocrRotateWork(List<Object> a) {
  if (!Platform.isAndroid) return -99;
  final lib = DynamicLibrary.open('libprofile_native.so');
  final rot = lib.lookupFunction<_RotN, _RotD>('pn_ocr_rotate');
  final ps = (a[0] as String).toNativeUtf8();
  final pd = (a[1] as String).toNativeUtf8();
  try {
    return rot(ps, pd, a[2] as int);
  } finally {
    calloc.free(ps);
    calloc.free(pd);
  }
}