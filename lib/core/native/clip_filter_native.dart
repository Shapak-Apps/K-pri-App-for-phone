import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef _ClassifyN = Int32 Function(Pointer<Utf8>);
typedef _ClassifyD = int Function(Pointer<Utf8>);

enum ClipSkip {
  translatable,   // 0
  empty,          // 1
  url,            // 2
  email,          // 3
  code,           // 4
  path,           // 5
  hash,           // 6
  numeric,        // 7
  emojiOnly,      // 8
  lowTextRatio,   // 9
}

class ClipFilterNative {
  static final ClipFilterNative instance = ClipFilterNative._();

  late final _ClassifyD _classify;
  bool _ok = false;
  bool get available => _ok;

  ClipFilterNative._() {
    try {
      final lib = Platform.isAndroid
          ? DynamicLibrary.open('libprofile_native.so')
          : DynamicLibrary.process();
      _classify =
          lib.lookupFunction<_ClassifyN, _ClassifyD>('pn_clip_classify');
      _ok = true;
      debugPrint('[clip_filter] C++ engine loaded ✔');
    } catch (e) {
      _ok = false;
      debugPrint('[clip_filter] C++ unavailable: $e');
    }
  }

  ClipSkip classify(String text) {
    if (!_ok || text.isEmpty) return ClipSkip.empty;
    final p = text.toNativeUtf8();
    try {
      final code = _classify(p);
      if (code < 0 || code >= ClipSkip.values.length) return ClipSkip.empty;
      return ClipSkip.values[code];
    } catch (e) {
      debugPrint('[clip_filter] classify error: $e');
      return ClipSkip.translatable;
    } finally {
      calloc.free(p);
    }
  }
}