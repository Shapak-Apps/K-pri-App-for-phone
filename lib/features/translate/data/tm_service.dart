import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import '../../history/data/history_models.dart';
import 'native/tm_native.dart';

class TmHit {
  final String dst;
  final int score;
  const TmHit(this.dst, this.score);
  bool get isExact => score >= 1000;
  bool get isFuzzy => score >= 800 && score < 1000;
}

class TmService {
  static final TmService instance = TmService._();
  TmService._();

  final _n = TmNative.instance;
  bool get isAvailable => _n.available;

  Future<void> rebuild(List<HistoryEntry> entries) async {
    if (!_n.available) return;
    await compute(_rebuildWork, {
      'n': entries.length,
      'srcs': entries.map((e) => e.source).toList(),
      'dsts': entries.map((e) => e.result).toList(),
      'froms': entries.map((e) => e.from).toList(),
      'tos': entries.map((e) => e.to).toList(),
    });
  }

  void add({
    required String src,
    required String dst,
    required String from,
    required String to,
  }) {
    if (!_n.available) return;
    if (src.trim().isEmpty || dst.trim().isEmpty) return;

    final pSrc = src.toNativeUtf8();
    final pDst = dst.toNativeUtf8();
    final pFrom = from.toNativeUtf8();
    final pTo = to.toNativeUtf8();
    try {
      _n.add(pSrc, pDst, pFrom, pTo);
    } finally {
      calloc.free(pSrc);
      calloc.free(pDst);
      calloc.free(pFrom);
      calloc.free(pTo);
    }
  }

  TmHit? lookup(String src, {required String from, required String to}) {
    if (!_n.available) return null;
    final s = src.trim();
    if (s.isEmpty) return null;

    final pSrc = s.toLowerCase().toNativeUtf8();
    final pFrom = from.toNativeUtf8();
    final pTo = to.toNativeUtf8();
    final buf = _n.lookupBuf;
    final bufSz = _n.lookupBufSize;
    try {
      final score = _n.lookup(pSrc, pFrom, pTo, buf, bufSz);
      if (score <= 0) return null;
      final dst = buf.cast<Utf8>().toDartString();
      if (dst.isEmpty) return null;
      return TmHit(dst, score);
    } catch (e) {
      debugPrint('[tm] lookup error: $e');
      return null;
    } finally {
      calloc.free(pSrc);
      calloc.free(pFrom);
      calloc.free(pTo);
    }
  }

  void clear() {
    if (!_n.available) return;
    _n.clear();
  }
}

Future<void> _rebuildWork(Map<String, dynamic> args) async {
  final native = TmNative.instance;
  if (!native.available) return;

  final n = args['n'] as int;
  final srcs = args['srcs'] as List<String>;
  final dsts = args['dsts'] as List<String>;
  final froms = args['froms'] as List<String>;
  final tos = args['tos'] as List<String>;

  if (n == 0) {
    native.clear();
    return;
  }

  final pSrcs = calloc<Pointer<Utf8>>(n);
  final pDsts = calloc<Pointer<Utf8>>(n);
  final pFroms = calloc<Pointer<Utf8>>(n);
  final pTos = calloc<Pointer<Utf8>>(n);

  try {
    for (int i = 0; i < n; i++) {
      pSrcs[i] = srcs[i].toNativeUtf8();
      pDsts[i] = dsts[i].toNativeUtf8();
      pFroms[i] = froms[i].toNativeUtf8();
      pTos[i] = tos[i].toNativeUtf8();
    }
    native.rebuild(n, pSrcs, pDsts, pFroms, pTos);
  } finally {
    for (int i = 0; i < n; i++) {
      calloc.free(pSrcs[i]);
      calloc.free(pDsts[i]);
      calloc.free(pFroms[i]);
      calloc.free(pTos[i]);
    }
    calloc.free(pSrcs);
    calloc.free(pDsts);
    calloc.free(pFroms);
    calloc.free(pTos);
  }
}