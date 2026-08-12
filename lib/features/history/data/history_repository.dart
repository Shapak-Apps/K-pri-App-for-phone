import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'history_models.dart';
import '../../translate/data/tm_service.dart';

class HistoryRepository extends ChangeNotifier {
  static const _boxName = 'history';
  late final Box<dynamic> _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    unawaited(_rebuildTm());
  }

  Future<void> _rebuildTm() async {
    try {
      await TmService.instance.rebuild(getAll());
    } catch (e) {
      debugPrint('[tm] rebuild error: $e');
    }
  }

  Future<void> add({
    required String source,
    required String result,
    required String from,
    required String to,
  }) async {
    if (source.trim().isEmpty || result.trim().isEmpty) return;
    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      source: source.trim(),
      result: result.trim(),
      from: from,
      to: to,
      timestamp: DateTime.now(),
    );
    await _box.put(entry.id, entry.toMap());
    TmService.instance.add(
      src: entry.source,
      dst: entry.result,
      from: entry.from,
      to: entry.to,
    );
    notifyListeners();
  }

  HistoryEntry _read(dynamic k) =>
      HistoryEntry.fromMap(Map<String, dynamic>.from(_box.get(k) as Map));

  List<HistoryEntry> getAll() {
    final list = _box.keys.map(_read).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<HistoryEntry> getFavorites() =>
      getAll().where((e) => e.isFavorite).toList();

  int get count => _box.length;
  int get favoritesCount => getFavorites().length;

  Future<void> toggleFavorite(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final e = HistoryEntry.fromMap(Map<String, dynamic>.from(raw));
    await _box.put(id, e.copyWith(isFavorite: !e.isFavorite).toMap());
    notifyListeners();
  }

  Future<int> clearFavorites() async {
    var n = 0;
    for (final k in _box.keys.toList()) {
      final e = _read(k);
      if (e.isFavorite) {
        await _box.put(k, e.copyWith(isFavorite: false).toMap());
        n++;
      }
    }
    if (n > 0) notifyListeners();
    return n;
  }

  Future<int> clear() async {
    final n = _box.length;
    await _box.clear();
    TmService.instance.clear();
    notifyListeners();
    return n;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> purgeOlderThan(int days) async {
    if (days <= 0) return;
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    var changed = false;
    for (final k in _box.keys.toList()) {
      final e = _read(k);
      if (e.timestamp.millisecondsSinceEpoch < cutoff) {
        await _box.delete(k);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  String exportJson() => jsonEncode(getAll().map((e) => e.toMap()).toList());

  Future<int> importJson(String raw) async {
    final list = jsonDecode(raw) as List<dynamic>;
    var n = 0;
    for (final m in list) {
      try {
        final e = HistoryEntry.fromMap(Map<String, dynamic>.from(m as Map));
        await _box.put(e.id, e.toMap());
        n++;
      } catch (_) {}
    }
    if (n > 0) {
      notifyListeners();
      unawaited(_rebuildTm());
    }
    return n;
  }
}