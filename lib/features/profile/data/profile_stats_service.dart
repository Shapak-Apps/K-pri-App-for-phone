import '../../history/data/history_repository.dart';
import 'native/profile_ffi.dart';

class ProfileStatsService {
  static final ProfileFFI _ffi = ProfileFFI();

  static List<dynamic> _entries(HistoryRepository repo) {
    final dynamic d = repo;
    try { final l = d.getAll(); if (l is List) return l; } catch (_) {}
    try { final l = d.entries; if (l is List) return l; } catch (_) {}
    try { final l = d.history; if (l is List) return l; } catch (_) {}
    return const [];
  }

  static int totalCount(HistoryRepository repo) {
    try {
      final dynamic d = repo;
      return (d.count as int?) ?? _entries(repo).length;
    } catch (_) {
      return 0;
    }
  }

  static String getMostUsedLanguage(HistoryRepository repo) {
    final codes = <String>[];
    for (final e in _entries(repo)) {
      try {
        final to = (e as dynamic).to as String?;
        if (to != null) codes.add(to);
      } catch (_) {}
    }
    final code = _ffi.topLanguage(codes);
    if (code.isEmpty) return '—';
    return _languageName(code);
  }

  static List<String> getTopPhrases(HistoryRepository repo) {
    final srcs = <String>[];
    for (final e in _entries(repo)) {
      try {
        final src = (e as dynamic).source as String?;
        if (src != null && src.isNotEmpty) srcs.add(src);
      } catch (_) {}
    }
    return _ffi.topPhrases(srcs, 5);
  }

  static String getPeakActivityHour(HistoryRepository repo) {
    final secs = _epochSeconds(repo);
    if (secs.isEmpty) return '—';
    return '${_ffi.getPeakHour(secs)}:00';
  }

  static int getAverageLength(HistoryRepository repo) {
    final lens = <int>[];
    for (final e in _entries(repo)) {
      try {
        final src = (e as dynamic).source as String?;
        if (src != null) lens.add(src.length);
      } catch (_) {}
    }
    return _ffi.getAverageLength(lens).round();
  }

  /// ⚡ Для WeeklyChart: 7 чисел за O(n) в C++
  static List<int> getWeeklyCounts(HistoryRepository repo) {
    return _ffi.weeklyCounts(_epochSeconds(repo));
  }

  static List<int> _epochSeconds(HistoryRepository repo) {
    final secs = <int>[];
    for (final e in _entries(repo)) {
      try {
        final ts = (e as dynamic).timestamp as DateTime?;
        if (ts != null) secs.add(ts.millisecondsSinceEpoch ~/ 1000);
      } catch (_) {}
    }
    return secs;
  }

  static String _languageName(String code) {
    const names = {
      'tk': 'Türkmençe', 'ru': 'Русский', 'en': 'English',
      'tr': 'Türkçe', 'de': 'Deutsch', 'fr': 'Français',
      'es': 'Español', 'it': 'Italiano',
    };
    return names[code] ?? code.toUpperCase();
  }
}