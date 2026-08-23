import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'native/profile_ffi.dart';

class ProfileRepository extends ChangeNotifier {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  static final ProfileFFI _ffi = ProfileFFI();

  Box<dynamic>? _box;
  String _dir = '';
  bool get isReady => _box != null;

  Future<void> ensureInit() async {
    if (_box != null) return;
    final doc = await getApplicationDocumentsDirectory();
    _dir = doc.path;
    _box = await Hive.openBox('profile');
    notifyListeners();
  }

  // ── Имя / био / цитата ────────────────────────────────
  String get name => (_box?.get('name', defaultValue: '') as String?) ?? '';
  Future<void> setName(String v) async {
    await ensureInit(); await _box!.put('name', v); notifyListeners();
  }

  String get bio => (_box?.get('bio', defaultValue: '') as String?) ?? '';
  Future<void> setBio(String v) async {
    await ensureInit(); await _box!.put('bio', v); notifyListeners();
  }

  String get favoriteQuote =>
      (_box?.get('favQuote', defaultValue: '') as String?) ?? '';
  Future<void> setFavoriteQuote(String v) async {
    await ensureInit(); await _box!.put('favQuote', v); notifyListeners();
  }

  // ── Аватар ────────────────────────────────────────────
  File get avatarFile => File('$_dir/profile_avatar.jpg');
  bool get hasAvatar => avatarFile.existsSync() && avatarFile.lengthSync() > 0;

  int get avatarVersion =>
      (_box?.get('avatarVersion', defaultValue: 0) as int?) ?? 0;

  String? get avatarEmoji => _box?.get('avatarEmoji') as String?;

  Future<void> setAvatarEmoji(String? e) async {
    await ensureInit();
    await _box!.put('avatarEmoji', e);
    if (e != null && hasAvatar) { try { await avatarFile.delete(); } catch (_) {} }
    await _box!.put('avatarVersion', avatarVersion + 1);
    _evictAvatarCache();
    notifyListeners();
  }

  static String? _resizeInBackground(Map<String, String> args) {
    return ProfileFFI().resizeAvatar(args['src']!, args['dst']!);
  }

  void _evictAvatarCache() {
    try {
      PaintingBinding.instance.imageCache.evict(FileImage(avatarFile));
    } catch (_) {}
  }

  Future<void> saveAvatarFromPath(String path) async {
    await ensureInit();
    final tmp = '$_dir/profile_avatar_tmp.jpg';

    String? resized;
    try {
      resized = await compute(_resizeInBackground, {'src': path, 'dst': tmp});
    } catch (_) {
      resized = null;
    }

    if (resized != null) {
      await File(resized).copy(avatarFile.path);
      try { await File(resized).delete(); } catch (_) {}
    } else {
      await File(path).copy(avatarFile.path);
    }

    await _box!.put('avatarEmoji', null);
    await _box!.put('avatarVersion', avatarVersion + 1);
    _evictAvatarCache();
    notifyListeners();
  }

  Future<void> deleteAvatar() async {
    await ensureInit();
    try { if (avatarFile.existsSync()) await avatarFile.delete(); } catch (_) {}
    await _box!.put('avatarEmoji', null);
    await _box!.put('avatarVersion', avatarVersion + 1);
    _evictAvatarCache();
    notifyListeners();
  }

  // ── XP / стрик / цель ─────────────────────────────────
  int get xp => (_box?.get('xp', defaultValue: 0) as int?) ?? 0;

  int get streak => (_box?.get('streak', defaultValue: 0) as int?) ?? 0;
  int get bestStreak => (_box?.get('bestStreak', defaultValue: 0) as int?) ?? 0;

  int get dailyGoal => (_box?.get('dailyGoal', defaultValue: 10) as int?) ?? 10;
  int get todayProgress =>
      (_box?.get('todayProgress', defaultValue: 0) as int?) ?? 0;

  Future<void> setDailyGoal(int g) async {
    await ensureInit(); await _box!.put('dailyGoal', g); notifyListeners();
  }

  Future<void> onTranslationDone() async {
    await ensureInit();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (_box!.get('lastGoalDate') != today) {
      await _box!.put('todayProgress', 1);
      await _box!.put('lastGoalDate', today);
    } else {
      await _box!.put('todayProgress', todayProgress + 1);
    }

    final last = _box!.get('lastActiveDate') as String?;
    if (last != today) {
      if (last == null) {
        await _box!.put('streak', 1);
      } else {
        final diff = DateTime.now().difference(DateTime.parse(last)).inDays;
        if (diff == 1) {
          final ns = streak + 1;
          await _box!.put('streak', ns);
          if (ns > bestStreak) await _box!.put('bestStreak', ns);
        } else if (diff > 1) {
          await _box!.put('streak', 1);
        }
      }
      await _box!.put('lastActiveDate', today);
    }

    await _box!.put('xp', xp + 5);
    await logActivity('translation', 1);
    notifyListeners();
  }

  // ── История активности ────────────────────────────────
  List<dynamic> get activityHistory =>
      (_box?.get('activityHistory', defaultValue: []) as List?) ?? [];

  Future<void> logActivity(String type, int count) async {
    await ensureInit();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final history = List<Map<String, dynamic>>.from(
      activityHistory.map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final ex = history.indexWhere((e) => e['date'] == today && e['type'] == type);
    if (ex >= 0) {
      history[ex]['count'] = ((history[ex]['count'] as int?) ?? 0) + count;
    } else {
      history.add({'date': today, 'type': type, 'count': count});
    }
    if (history.length > 365) history.removeRange(0, history.length - 365);
    await _box!.put('activityHistory', history);
  }

  int _dateToInt(String iso) {
    final p = iso.split('-');
    if (p.length != 3) return 0;
    final y = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    final d = int.tryParse(p[2]) ?? 0;
    return y * 10000 + m * 100 + d;
  }

  Future<void> recalculateStreak() async {
    await ensureInit();
    final dates = <int>[];
    for (final e in activityHistory) {
      try {
        final s = (e as Map)['date'] as String?;
        if (s != null) {
          final v = _dateToInt(s);
          if (v > 0) dates.add(v);
        }
      } catch (_) {}
    }
    if (dates.isEmpty) {
      await _box!.put('streak', 0);
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final today = now.year * 10000 + now.month * 100 + now.day;

    final s = _ffi.calculateStreak(dates, today);
    final b = _ffi.calculateBestStreak(dates);

    await _box!.put('streak', s);
    if (b > bestStreak) await _box!.put('bestStreak', b);
    notifyListeners();
  }

  // ── Бейджи ────────────────────────────────────────────
  Map<String, dynamic> get badgeDates =>
      Map<String, dynamic>.from(
          (_box?.get('badgeDates', defaultValue: {}) as Map?) ?? {});

  Future<void> markBadge(String id) async {
    await ensureInit();
    final d = badgeDates;
    if (!d.containsKey(id)) {
      d[id] = DateTime.now().toIso8601String().substring(0, 10);
      await _box!.put('badgeDates', d);
      notifyListeners();
    }
  }

  // ── Очистка ───────────────────────────────────────────
  Future<void> clearAll() async {
    await ensureInit();
    await _box!.clear();
    try { if (avatarFile.existsSync()) await avatarFile.delete(); } catch (_) {}
    _evictAvatarCache();
    notifyListeners();
  }
}