import 'dart:ffi';
import 'dart:math' as math;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import 'profile_bindings.dart';

class ProfileFFI {
  static final ProfileFFI _instance = ProfileFFI._();
  factory ProfileFFI() => _instance;

  ProfileFFI._() {
    try {
      _b = ProfileNativeBindings();
      _native = true;
      debugPrint('[ffi] libprofile_native.so loaded ✔');
    } catch (e) {
      _b = null;
      _native = false;
      debugPrint('[ffi] native unavailable → Dart fallback: $e');
    }
  }

  ProfileNativeBindings? _b;
  bool _native = false;
  bool get isNativeAvailable => _native;

  // ═══ XP ═══
  int getLevel(int xp) => _native ? _b!.level(xp) : _dartLevel(xp);
  int getXpForNextLevel(int xp) => _native ? _b!.xpNext(xp) : _dartXpSum(_dartLevel(xp));
  int getXpForCurrentLevel(int xp) {
    if (_native) return _b!.xpCurrent(xp);
    final l = _dartLevel(xp);
    return l == 1 ? 0 : _dartXpSum(l - 1);
  }
  double getLevelProgress(int xp) {
    if (_native) return _b!.levelProgress(xp);
    final cur = getXpForCurrentLevel(xp);
    final nxt = getXpForNextLevel(xp);
    final need = nxt - cur;
    if (need <= 0) return 0.0;
    return ((xp - cur) / need).clamp(0.0, 1.0);
  }

  // ═══ STREAK ═══
  int calculateStreak(List<int> ymd, int todayYmd) {
    if (ymd.isEmpty) return 0;
    if (_native) return _withI32(ymd, (p) => _b!.streakCurrent(p, ymd.length, todayYmd));
    return _dartStreak(ymd, todayYmd);
  }

  int calculateBestStreak(List<int> ymd) {
    if (ymd.isEmpty) return 0;
    if (_native) return _withI32(ymd, (p) => _b!.streakBest(p, ymd.length));
    return _dartBestStreak(ymd);
  }

  // ═══ СТАТИСТИКА ═══
  int getPeakHour(List<int> epochSec) {
    if (epochSec.isEmpty) return 0;
    if (_native) return _withI32(epochSec, (p) => _b!.peakHour(p, epochSec.length));
    return _dartPeak(epochSec);
  }

  List<int> weeklyCounts(List<int> epochSec) {
    if (_native && epochSec.isNotEmpty) {
      final inp = calloc<Int32>(epochSec.length);
      final out = calloc<Int32>(7);
      try {
        for (var i = 0; i < epochSec.length; i++) inp[i] = epochSec[i];
        _b!.weeklyCounts(inp, epochSec.length,
            DateTime.now().millisecondsSinceEpoch ~/ 1000, out);
        return List.generate(7, (i) => out[i]);
      } finally {
        calloc.free(inp);
        calloc.free(out);
      }
    }
    return _dartWeekly(epochSec);
  }

  double getAverageLength(List<int> lens) {
    if (lens.isEmpty) return 0.0;
    if (_native) {
      final p = calloc<Int32>(lens.length);
      try {
        for (var i = 0; i < lens.length; i++) p[i] = lens[i];
        return _b!.avgLength(p, lens.length);
      } finally {
        calloc.free(p);
      }
    }
    return lens.reduce((a, b) => a + b) / lens.length;
  }

  String topLanguage(List<String> codes) {
    if (codes.isEmpty) return '';
    if (_native) {
      final keep = <Pointer<Utf8>>[];
      final arr = _allocStrings(codes, keep);
      final out = calloc<Uint8>(64).cast<Utf8>();
      try {
        _b!.topLanguage(arr, codes.length, out, 64);
        return out.toDartString();
      } finally {
        calloc.free(arr);
        calloc.free(out);
        for (final p in keep) calloc.free(p);
      }
    }
    return _dartTopLang(codes);
  }

  List<String> topPhrases(List<String> srcs, int k) {
    if (srcs.isEmpty) return const [];
    if (_native) {
      final keep = <Pointer<Utf8>>[];
      final arr = _allocStrings(srcs, keep);
      final out = calloc<Uint8>(8192).cast<Utf8>();
      try {
        _b!.topPhrases(arr, srcs.length, k, out, 8192);
        final s = out.toDartString();
        return s.isEmpty ? const [] : s.split('\n');
      } finally {
        calloc.free(arr);
        calloc.free(out);
        for (final p in keep) calloc.free(p);
      }
    }
    return _dartTopPhrases(srcs, k);
  }

  // ═══ JSON → CSV (полностью в C++) ═══
  String? jsonToCsv(String json) {
    if (!_native) return null;
    final inp = json.toNativeUtf8();
    var size = json.length * 3 + 4096;
    try {
      for (var attempt = 0; attempt < 6; attempt++) {
        final out = calloc<Uint8>(size);
        try {
          final r = _b!.jsonToCsv(inp, out, size);
          if (r >= 0) return out.cast<Utf8>().toDartString();
          if (r == -2) { size *= 2; continue; }
          return null;
        } finally {
          calloc.free(out);
        }
      }
      return null;
    } finally {
      calloc.free(inp);
    }
  }

  int jsonCount(String json) {
    if (!_native) return -1;
    final p = json.toNativeUtf8();
    try {
      return _b!.jsonCount(p);
    } finally {
      calloc.free(p);
    }
  }

  // ═══ Ресайз аватара в C++ (мгновенное применение фото) ═══
  String? resizeAvatar(String src, String dst, {int maxSide = 512, int quality = 88}) {
    if (!_native) return null;
    final s = src.toNativeUtf8();
    final d = dst.toNativeUtf8();
    try {
      return _b!.imageResize(s, d, maxSide, quality) == 0 ? dst : null;
    } finally {
      calloc.free(s);
      calloc.free(d);
    }
  }

  // ═══ helpers ═══
  int _withI32(List<int> data, int Function(Pointer<Int32>) fn) {
    final p = calloc<Int32>(data.length);
    try {
      for (var i = 0; i < data.length; i++) p[i] = data[i];
      return fn(p);
    } finally {
      calloc.free(p);
    }
  }

  Pointer<Pointer<Utf8>> _allocStrings(List<String> strs, List<Pointer<Utf8>> keep) {
    final ptr = calloc<Pointer<Utf8>>(strs.length);
    for (var i = 0; i < strs.length; i++) {
      final p = strs[i].toNativeUtf8();
      keep.add(p);
      ptr[i] = p;
    }
    return ptr;
  }

  // ═══ DART FALLBACK ═══
  static const int _baseXp = 100;
  static const double _growth = 1.15;

  int _dartLevel(int xp) {
    var level = 1, total = 0;
    while (level <= 100) {
      final need = (_baseXp * math.pow(_growth, level - 1)).round();
      if (total + need > xp) break;
      total += need;
      level++;
    }
    return level;
  }

  int _dartXpSum(int level) {
    var t = 0;
    for (var i = 1; i <= level; i++) {
      t += (_baseXp * math.pow(_growth, i - 1)).round();
    }
    return t;
  }

  int _addDays(int ymd, int days) {
    final dt = DateTime(ymd ~/ 10000, (ymd ~/ 100) % 100, ymd % 100)
        .add(Duration(days: days));
    return dt.year * 10000 + dt.month * 100 + dt.day;
  }

  int _dartStreak(List<int> dates, int today) {
    final set = dates.toSet();
    var start = today;
    if (!set.contains(start)) start = _addDays(today, -1);
    if (!set.contains(start)) return 0;
    var s = 0, cur = start;
    while (set.contains(cur)) { s++; cur = _addDays(cur, -1); }
    return s;
  }

  int _dartBestStreak(List<int> dates) {
    final set = dates.toSet();
    var best = 0;
    for (final d in set) {
      if (set.contains(_addDays(d, -1))) continue;
      var cur = d, len = 0;
      while (set.contains(cur)) { len++; cur = _addDays(cur, 1); }
      if (len > best) best = len;
    }
    return best;
  }

  int _dartPeak(List<int> epochSec) {
    final b = List<int>.filled(24, 0);
    for (final s in epochSec) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s * 1000);
      b[dt.hour]++;
    }
    var peak = 0;
    for (var h = 1; h < 24; h++) if (b[h] > b[peak]) peak = h;
    return peak;
  }

  List<int> _dartWeekly(List<int> epochSec) {
    final out = List<int>.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final s in epochSec) {
      final dt = DateTime.fromMillisecondsSinceEpoch(s * 1000);
      final d = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(d).inDays;
      if (diff >= 0 && diff < 7) out[6 - diff]++;
    }
    return out;
  }

  String _dartTopLang(List<String> codes) {
    final m = <String, int>{};
    for (final c in codes) m[c] = (m[c] ?? 0) + 1;
    if (m.isEmpty) return '';
    return m.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  List<String> _dartTopPhrases(List<String> srcs, int k) {
    final m = <String, int>{};
    for (final s in srcs) if (s.isNotEmpty) m[s] = (m[s] ?? 0) + 1;
    return (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(k).map((e) => e.key).toList();
  }
}