import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_photo_model.dart';

class CameraRepository extends ChangeNotifier {
  CameraRepository._();
  static final CameraRepository instance = CameraRepository._();

  static const _boxName = 'camera_photos';
  Box<dynamic>? _box;
  String _dir = '';

  String get photosDir => _dir;
  bool get isReady => _box != null;

  Future<void> ensureInit() async {
    if (_box != null) return;
    final doc = await getApplicationDocumentsDirectory();
    _dir = '${doc.path}/camera_photos';
    await Directory(_dir).create(recursive: true);
    _box = await Hive.openBox(_boxName);
  }

  List<CameraPhoto> getAll() {
    final b = _box;
    if (b == null) return const [];
    final list = b.keys.map((k) {
      return CameraPhoto.fromMap(Map<String, dynamic>.from(b.get(k) as Map));
    }).toList();
    list.sort((a, c) => c.timestamp.compareTo(a.timestamp)); // новые сверху
    return list;
  }

  int get count => _box?.length ?? 0;

  Future<void> add(CameraPhoto p) async {
    await ensureInit();
    await _box!.put(p.id, p.toMap());
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await ensureInit();
    final raw = _box!.get(id);
    if (raw != null) {
      final p = CameraPhoto.fromMap(Map<String, dynamic>.from(raw as Map));
      try {
        final f = File(p.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    await _box!.delete(id);
    notifyListeners();
  }

  /// Удаляет все фото + файлы. Возвращает число удалённых.
  Future<int> clearAll() async {
    await ensureInit();
    final all = getAll();
    for (final p in all) {
      try {
        final f = File(p.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    final n = _box!.length;
    await _box!.clear();
    notifyListeners();
    return n;
  }
}