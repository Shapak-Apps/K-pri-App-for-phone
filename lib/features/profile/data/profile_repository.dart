import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'native/profile_ffi.dart';
import 'profile_goals_service.dart';

class ProfileRepository extends ChangeNotifier {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  static final ProfileFFI _ffi = ProfileFFI();

  static const Duration _windowLength = Duration(hours: 24);

  Box<dynamic>? _box;
  String _dir = '';
  bool get isReady => _box != null;

  /// In-memory: last awarded XP (for UI toasts). Not persisted.
  int lastXpAwarded = 0;

  /// In-memory: character count of the last awarded translation (for toasts).
  int lastXpChars = 0;

  Future<void> ensureInit() async {
    if (_box != null) return;
    final doc = await getApplicationDocumentsDirectory();
    _dir = doc.path;
    _box = await Hive.openBox('profile');
    await _antiClockCheat();
    await _ensureWindow();
    await evaluateAndRollWindow();
    notifyListeners();
  }

  // ── Name / bio / quote ────────────────────────────────
  String get name => (_box?.get('name', defaultValue: '') as String?) ?? '';
  Future<void> setName(String v) async {
    await ensureInit();
    await _box!.put('name', v);
    notifyListeners();
  }

  String get bio => (_box?.get('bio', defaultValue: '') as String?) ?? '';
  Future<void> setBio(String v) async {
    await ensureInit();
    await _box!.put('bio', v);
    notifyListeners();
  }

  String get favoriteQuote =>
      (_box?.get('favQuote', defaultValue: '') as String?) ?? '';
  Future<void> setFavoriteQuote(String v) async {
    await ensureInit();
    await _box!.put('favQuote', v);
    notifyListeners();
  }

  // ── Avatar ────────────────────────────────────────────
  File get avatarFile => File('$_dir/profile_avatar.jpg');
  bool get hasAvatar => avatarFile.existsSync() && avatarFile.lengthSync() > 0;

  int get avatarVersion =>
      (_box?.get('avatarVersion', defaultValue: 0) as int?) ?? 0;

  String? get avatarEmoji => _box?.get('avatarEmoji') as String?;

  Future<void> setAvatarEmoji(String? e) async {
    await ensureInit();
    await _box!.put('avatarEmoji', e);
    if (e != null && hasAvatar) {
      try {
        await avatarFile.delete();
      } catch (_) {}
    }
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
      try {
        await File(resized).delete();
      } catch (_) {}
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
    try {
      if (avatarFile.existsSync()) await avatarFile.delete();
    } catch (_) {}
    await _box!.put('avatarEmoji', null);
    await _box!.put('avatarVersion', avatarVersion + 1);
    _evictAvatarCache();
    notifyListeners();
  }

  // ── XP / streak / goal ────────────────────────────────
  int get xp => (_box?.get('xp', defaultValue: 0) as int?) ?? 0;

  int get streak => (_box?.get('streak', defaultValue: 0) as int?) ?? 0;
  int get bestStreak => (_box?.get('bestStreak', defaultValue: 0) as int?) ?? 0;

  // ── GOAL LADDER (24h rolling windows) ────────────────────────────────────
  int get goalRung => (_box?.get('goalRung', defaultValue: 0) as int?) ?? 0;

  int get dailyGoal => ProfileGoalsService.rungToGoal(goalRung);

  int get nextGoal => ProfileGoalsService.nextGoal(goalRung);

  int get fallbackGoal => ProfileGoalsService.prevGoal(goalRung);

  /// Progress inside the CURRENT window. FROZEN once the goal is completed.
  int get todayProgress =>
      (_box?.get('todayProgress', defaultValue: 0) as int?) ?? 0;

  /// TRUE once the current window's goal is completed.
  /// While true, [todayProgress] no longer increments ("counter killed"),
  /// but the countdown keeps running until the window expires.
  bool get goalCompletedInWindow =>
      (_box?.get('goalDoneInWindow', defaultValue: false) as bool?) ?? false;

  /// One-shot flag: UI shows the celebration dialog once per window.
  bool get goalCelebrationPending =>
      (_box?.get('goalCelebratePending', defaultValue: false) as bool?) ??
      false;

  /// UI calls this after showing the celebration dialog.
  Future<void> consumeGoalCelebration() async {
    if (_box == null) return;
    await _box!.put('goalCelebratePending', false);
    notifyListeners();
  }

  /// Window deadline (epoch ms). The countdown is derived from this value,
  /// so it keeps ticking even while the app is fully closed.
  int get goalDeadlineMs =>
      (_box?.get('goalDeadlineMs', defaultValue: 0) as int?) ?? 0;

  int get goalRemainingMs {
    final d = goalDeadlineMs;
    if (d == 0) return _windowLength.inMilliseconds;
    final left = d - DateTime.now().millisecondsSinceEpoch;
    return left < 0 ? 0 : left;
  }

  bool get goalWindowExpired => goalRemainingMs <= 0;

  // ── SMART XP STATE (anti-grind, per 24h window) ───────────────────────────
  int get translationsToday =>
      (_box?.get('translationsToday', defaultValue: 0) as int?) ?? 0;

  int get todayXpEarned => (_box?.get('xpToday', defaultValue: 0) as int?) ?? 0;

  int get level => _ffi.getLevel(xp);

  int get dailyXpCap => _ffi.dailyXpCap(level);

  bool get dailyXpCapReached => todayXpEarned >= dailyXpCap;

  double get xpMultiplier => _ffi.xpMultiplier(translationsToday);

  Future<void> setDailyGoal(int g) async {
    await ensureInit();
    await _box!.put('goalRung', ProfileGoalsService.goalToRung(g));
    notifyListeners();
  }

  // ── WINDOW MANAGEMENT ────────────────────────────────────────────────────
  Future<void> _ensureWindow() async {
    if (_box == null) return;
    if (goalDeadlineMs == 0) {
      await _box!.put(
        'goalDeadlineMs',
        DateTime.now().millisecondsSinceEpoch + _windowLength.inMilliseconds,
      );
      await _box!.put('lastSeenMs', DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Anti-cheat: clock rewound → window expires immediately.
  Future<void> _antiClockCheat() async {
    if (_box == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastSeen = (_box!.get('lastSeenMs', defaultValue: 0) as int?) ?? 0;
    if (lastSeen > 0 && now < lastSeen - 60000) {
      await _box!.put('goalDeadlineMs', 0);
    }
    if (now > lastSeen) await _box!.put('lastSeenMs', now);
  }

  /// Evaluates the finished window and starts a new one:
  /// completed → escalate rung; failed → demote rung + streak reset.
  /// No-op while the window is still active.
  Future<void> evaluateAndRollWindow() async {
    if (_box == null) return;
    final deadline = goalDeadlineMs;
    if (deadline == 0) {
      await _ensureWindow();
      return;
    }
    if (DateTime.now().millisecondsSinceEpoch < deadline) return; // active

    final done = todayProgress;
    if (done >= dailyGoal) {
      await _box!.put('goalRung', goalRung + 1); // SUCCESS: next rung
    } else {
      await _box!.put('goalRung', goalRung - 1); // FAILURE: rung down
      await _box!.put('streak', 0); // punishment: fire goes out
    }

    // Fresh window: counters, flags, new 24:00:00 deadline.
    await _box!.put('todayProgress', 0);
    await _box!.put('translationsToday', 0);
    await _box!.put('xpToday', 0);
    await _box!.put('goalDoneInWindow', false);
    await _box!.put('goalCelebratePending', false);
    await _box!.put(
      'goalDeadlineMs',
      DateTime.now().millisecondsSinceEpoch + _windowLength.inMilliseconds,
    );
    notifyListeners();
  }

  // ── TRANSLATION → SMART XP ───────────────────────────────────────────────
  Future<int> onTranslationDone({
    String sourceText = '',
    String resultText = '',
    String targetLanguage = '',
  }) async {
    await ensureInit();
    await evaluateAndRollWindow();

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // ── GOAL COUNTER: frozen after completion ───────────────────────────────
    final alreadyDone = goalCompletedInWindow;
    var bonus = 0;
    if (!alreadyDone) {
      final newProgress = todayProgress + 1;
      await _box!.put('todayProgress', newProgress);
      if (newProgress >= dailyGoal) {
        // Goal completed: freeze counter, schedule celebration, grant bonus.
        await _box!.put('goalDoneInWindow', true);
        await _box!.put('goalCelebratePending', true);
        bonus = 100 + (streak * 10).clamp(0, 200);
      }
    }
    // Anti-grind counter keeps running (invisible to user).
    final doneBefore = translationsToday;
    await _box!.put('translationsToday', doneBefore + 1);

    // Streak (calendar-day activity).
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

    // 1. Char-based XP from the C++ engine.
    final chars = _countChars(resultText);
    final base = _ffi.computeTranslationXp(
      charCount: chars,
      isRareLanguage: _isRareLanguage(targetLanguage),
      isFirstInWindow: doneBefore == 0,
    );

    // 2. Diminishing returns.
    var awarded = (base * _ffi.xpMultiplier(doneBefore)).round();

    // 3. Window XP cap.
    final capLeft = dailyXpCap - todayXpEarned;
    if (capLeft <= 0) {
      awarded = 0;
    } else if (awarded > capLeft) {
      awarded = capLeft;
    }

    // 4. Goal bonus bypasses the cap.
    await _box!.put('xp', xp + awarded + bonus);
    await _box!.put('xpToday', todayXpEarned + awarded);
    lastXpAwarded = awarded + bonus;
    lastXpChars = chars;

    await logActivity('translation', 1);
    notifyListeners();
    return awarded + bonus;
  }

  /// Counts letters only (no spaces/punctuation).
  static int _countChars(String text) => text
      .replaceAll(RegExp(r'[^a-zA-Zа-яА-ЯёЁçÇöÖüÜşŞğĞıIäÄæÆňŇöÖüÜýÝžŽ]'), '')
      .length;

  static bool _isRareLanguage(String code) {
    const common = {'en', 'ru', 'tk', 'tr'};
    return !common.contains(code.toLowerCase());
  }

  // ── Activity history ──────────────────────────────────
  List<dynamic> get activityHistory =>
      (_box?.get('activityHistory', defaultValue: []) as List?) ?? [];

  Future<void> logActivity(String type, int count) async {
    await ensureInit();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final history = List<Map<String, dynamic>>.from(
      activityHistory.map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final ex = history.indexWhere(
      (e) => e['date'] == today && e['type'] == type,
    );
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

  // ── Badges ────────────────────────────────────────────
  Map<String, dynamic> get badgeDates => Map<String, dynamic>.from(
    (_box?.get('badgeDates', defaultValue: {}) as Map?) ?? {},
  );

  Future<void> markBadge(String id) async {
    await ensureInit();
    final d = badgeDates;
    if (!d.containsKey(id)) {
      d[id] = DateTime.now().toIso8601String().substring(0, 10);
      await _box!.put('badgeDates', d);
      notifyListeners();
    }
  }

  // ── Cleanup ──────────────────────────────────────────
  Future<void> clearAll() async {
    await ensureInit();
    await _box!.clear();
    lastXpAwarded = 0;
    lastXpChars = 0;
    await _ensureWindow();
    try {
      if (avatarFile.existsSync()) await avatarFile.delete();
    } catch (_) {}
    _evictAvatarCache();
    notifyListeners();
  }
}
