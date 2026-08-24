import 'package:hive_flutter/hive_flutter.dart';
import 'srs_native.dart';

class SrsData {
  final int reps;
  final double ef;
  final int interval;
  final int dueMs;
  final int lapses;
  final int lastReviewMs;

  const SrsData({
    this.reps = 0,
    this.ef = 2.5,
    this.interval = 0,
    this.dueMs = 0,
    this.lapses = 0,
    this.lastReviewMs = 0,
  });

  bool get isNew => lastReviewMs == 0;

  Map<String, dynamic> toMap() => {
    'reps': reps,
    'ef': ef,
    'interval': interval,
    'dueMs': dueMs,
    'lapses': lapses,
    'lastReviewMs': lastReviewMs,
  };

  static SrsData fromMap(Map? m) {
    if (m == null) return const SrsData();
    return SrsData(
      reps: (m['reps'] as int?) ?? 0,
      ef: ((m['ef'] as num?) ?? 2.5).toDouble(),
      interval: (m['interval'] as int?) ?? 0,
      dueMs: (m['dueMs'] as int?) ?? 0,
      lapses: (m['lapses'] as int?) ?? 0,
      lastReviewMs: (m['lastReviewMs'] as int?) ?? 0,
    );
  }
}

class SrsScheduler {
  static const String boxName = 'srs_meta';
  static const double _minEf = 1.3;
  static const double _maxEf = 2.8;
  static const int _maxInterval = 36500;
  static const int _dayMs = 86400000;

  static Box? _box;

  static Future<Box> _open() async {
    _box ??= await Hive.openBox(boxName);
    return _box!;
  }

  static SrsData get(String cardId, Box box) =>
      SrsData.fromMap(box.get(cardId) as Map?);

  static Future<SrsData> review(
    String cardId,
    int quality, {
    DateTime? now,
  }) async {
    final box = await _open();
    final cur = get(cardId, box);
    final nowMs = (now ?? DateTime.now()).millisecondsSinceEpoch;

    SrsData next;
    final native = SrsNative.instance.review(
      reps: cur.reps,
      ef: cur.ef,
      interval: cur.interval,
      quality: quality,
      nowMs: nowMs,
    );

    if (native != null) {
      next = SrsData(
        reps: native.reps,
        ef: native.ef,
        interval: native.interval,
        dueMs: native.dueMs,
        lapses: cur.lapses + (quality < 3 ? 1 : 0),
        lastReviewMs: nowMs,
      );
    } else {
      next = _dartReview(cur, quality, nowMs);
    }

    await box.put(cardId, next.toMap());
    return next;
  }

  static SrsData _dartReview(SrsData cur, int quality, int nowMs) {
    var reps = cur.reps.clamp(0, 1000000);
    var ef = (cur.ef.isFinite && cur.ef > 0)
        ? cur.ef.clamp(_minEf, _maxEf)
        : 2.5;
    var interval = cur.interval.clamp(0, _maxInterval);
    final q = quality.clamp(0, 5);

    if (q < 3) {
      reps = 0;
      interval = 1;
    } else {
      if (reps == 0) {
        interval = 1;
      } else if (reps == 1) {
        interval = 6;
      } else {
        var next = interval * ef;
        if (!next.isFinite) next = _maxInterval.toDouble();
        interval = next.round().clamp(1, _maxInterval);
      }
      reps += 1;
    }

    final delta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    ef = (ef + delta).clamp(_minEf, _maxEf);

    final add = interval * _dayMs;
    final due = (add > (DateTime.now().millisecondsSinceEpoch))
        ? nowMs + add
        : nowMs + add;

    return SrsData(
      reps: reps,
      ef: ef,
      interval: interval,
      dueMs: due,
      lapses: cur.lapses + (quality < 3 ? 1 : 0),
      lastReviewMs: nowMs,
    );
  }

  static Future<List<String>> pickSession(List<String> ids, int limit) async {
    if (ids.isEmpty || limit <= 0) return [];
    final box = await _open();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final due = List<int>.generate(ids.length, (i) {
      return get(ids[i], box).dueMs;
    });

    final native = SrsNative.instance.dueIndices(due, nowMs, limit);
    final idx = native ?? _dartDue(due, nowMs, limit);
    return [for (final i in idx) ids[i]];
  }

  static List<int> _dartDue(List<int> due, int nowMs, int limit) {
    final pairs = <MapEntry<int, int>>[];
    for (var i = 0; i < due.length; i++) {
      if (due[i] <= nowMs) pairs.add(MapEntry(due[i], i));
    }
    if (pairs.isEmpty) return [];
    pairs.sort((a, b) {
      if (a.key != b.key) return a.key.compareTo(b.key);
      return a.value.compareTo(b.value);
    });
    final take = limit < pairs.length ? limit : pairs.length;
    return [for (var k = 0; k < take; k++) pairs[k].value];
  }
}
