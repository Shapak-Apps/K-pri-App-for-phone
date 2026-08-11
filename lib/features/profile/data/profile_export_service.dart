import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../history/data/history_repository.dart';
import 'native/profile_ffi.dart';

class ProfileExportService {
  static final ProfileFFI _ffi = ProfileFFI();

  static Future<String> exportHistoryToJson(HistoryRepository repo) async {
    final dynamic r = repo;
    return (r.exportJson() as String?) ?? '[]';
  }

  static Future<String> exportHistoryToCsv(HistoryRepository repo) async {
    final json = await exportHistoryToJson(repo);
    // ⚡ Полноценный CSV-движок в C++ (настоящий JSON-парсер)
    final native = _ffi.jsonToCsv(json);
    if (native != null) return native;
    // Dart fallback
    final sb = StringBuffer()..writeln('source,result,from,to,starred');
    for (final e in extractList(jsonDecode(json))) {
      final m = e as Map<String, dynamic>;
      sb.writeln('"${_esc('${m['source'] ?? ''}')}",'
          '"${_esc('${m['result'] ?? ''}')}",'
          '"${m['from'] ?? ''}","${m['to'] ?? ''}",'
          '"${m['starred'] ?? false}"');
    }
    return sb.toString();
  }

  static Future<int> importFromJson(HistoryRepository repo, String json) async {
    final dynamic r = repo;
    final n = await r.importJson(json);
    return (n as int?) ?? 0;
  }

  static List<dynamic> extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      if (decoded['history'] is List) return decoded['history'] as List;
      for (final v in decoded.values) {
        if (v is List) return v;
      }
    }
    return const [];
  }

  /// ⚡ Быстрый подсчёт записей в C++
  static int countEntries(String json) {
    final n = _ffi.jsonCount(json);
    if (n >= 0) return n;
    return extractList(jsonDecode(json)).length;
  }

  static Future<File> saveToFile(String content, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    return file;
  }

  static String _esc(String v) =>
      v.replaceAll('"', '""').replaceAll('\n', ' ').replaceAll('\r', '');
}