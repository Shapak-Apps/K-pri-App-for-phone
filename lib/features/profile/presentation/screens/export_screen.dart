import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/controllers/app_settings_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../history/data/history_repository.dart';
import '../../data/profile_export_service.dart';

class ExportScreen extends StatelessWidget {
  final HistoryRepository repo;
  const ExportScreen({super.key, required this.repo});

  void _snack(BuildContext context, String t, {bool warn = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t),
      backgroundColor: warn ? context.c.warn : context.c.accent,
    ));
  }

  // ── EXPORT JSON ────────────────────────────────────────
  Future<void> _exportJson(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final json = await ProfileExportService.exportHistoryToJson(repo);
      final list = ProfileExportService.extractList(jsonDecode(json));

      // ← ПРОВЕРКА: история пустая?
      if (list.isEmpty) {
        _snack(context, l10n.t('export_empty'), warn: true);
        return;
      }

      await ProfileExportService.saveToFile(json, 'kopri_history.json');
      await Clipboard.setData(ClipboardData(text: json));

      // ← ПОНЯТНОЕ сообщение: сколько записей и куда
      _snack(context, '${l10n.t('export_done')} ${list.length} · ${l10n.t('export_clipboard')}');
    } catch (e) {
      _snack(context, l10n.t('export_error'), warn: true);
    }
  }

  // ── EXPORT CSV ─────────────────────────────────────────
  Future<void> _exportCsv(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final json = await ProfileExportService.exportHistoryToJson(repo);
      final list = ProfileExportService.extractList(jsonDecode(json));

      if (list.isEmpty) {
        _snack(context, l10n.t('export_empty'), warn: true);
        return;
      }

      final csv = await ProfileExportService.exportHistoryToCsv(repo);
      final f = await ProfileExportService.saveToFile(csv, 'kopri_history.csv');
      _snack(context, '${l10n.t('export_done')} ${list.length} · CSV');
    } catch (e) {
      _snack(context, l10n.t('export_error'), warn: true);
    }
  }

  // ── IMPORT (с проверками ДО импорта) ───────────────────
  Future<void> _doImport(BuildContext context, String raw) async {
    final l10n = context.l10n;
    final text = raw.trim();

    // 1) Пустое поле
    if (text.isEmpty) {
      _snack(context, l10n.t('import_empty_field'), warn: true);
      return;
    }

    // 2) Это вообще JSON?
    dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      _snack(context, l10n.t('import_bad_format'), warn: true);
      return;
    }

    // 3) Есть ли там записи? (ловим случай с «[]»)
    final list = ProfileExportService.extractList(decoded);
    if (list.isEmpty) {
      _snack(context, l10n.t('import_empty'), warn: true);
      return;
    }

    // 4) Импорт
    try {
      final n = await ProfileExportService.importFromJson(repo, text);
      _snack(context, '${l10n.t('import_done')} ${n > 0 ? n : list.length}');
    } catch (_) {
      _snack(context, l10n.t('import_bad_format'), warn: true);
    }
  }

  void _importDialog(BuildContext context) {
    final c = context.c, l10n = context.l10n;
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.t('profile_import'),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ← подсказка «как пользоваться»
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: c.accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.t('import_howto'),
                      style: TextStyle(color: c.sub, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 5,
              style: TextStyle(color: c.text, fontSize: 12),
              decoration: InputDecoration(
                hintText: l10n.t('profile_import_hint'),
                hintStyle: TextStyle(color: c.faint),
                filled: true,
                fillColor: c.surfaceHi,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final text = ctrl.text;
              Navigator.pop(ctx);
              await _doImport(context, text);
            },
            child: Text(l10n.t('confirm'),
                style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.t('cancel'), style: TextStyle(color: c.sub)),
          ),
        ],
      ),
    );
  }

  // ── ОЧИСТКА СТАРЫХ ─────────────────────────────────────
  void _clearOldDialog(BuildContext context) {
    final c = context.c, l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.t('profile_clear_old'),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [30, 90, 365]
              .map((d) => ListTile(
            dense: true,
            title: Text('$d ${l10n.t('profile_days')}',
                style: TextStyle(color: c.text)),
            onTap: () async {
              Navigator.pop(ctx);
              try {
                final dynamic r = repo;
                await r.purgeOlderThan(d);
                _snack(context, l10n.t('profile_cleared'));
              } catch (_) {
                _snack(context, l10n.t('export_error'), warn: true);
              }
            },
          ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        foregroundColor: c.text,
        title: Text(l10n.t('profile_export'),
            style: AppTheme.display(size: 18, color: c.text)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _tile(c, Icons.data_object_rounded, 'JSON', l10n.t('export_json_desc'),
                  () => _exportJson(context)),
          const SizedBox(height: 10),
          _tile(c, Icons.table_view_rounded, 'CSV', l10n.t('export_csv_desc'),
                  () => _exportCsv(context)),
          const SizedBox(height: 10),
          _tile(c, Icons.download_rounded, l10n.t('profile_import'),
              l10n.t('import_desc'), () => _importDialog(context)),
          const SizedBox(height: 10),
          _tile(c, Icons.delete_sweep_rounded, l10n.t('profile_clear_old'),
              l10n.t('clear_old_desc'), () => _clearOldDialog(context),
              warn: true),
        ],
      ),
    );
  }

  Widget _tile(AppColors c, IconData icon, String title, String sub,
      VoidCallback onTap, {bool warn = false}) {
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(icon, color: warn ? c.warn : c.accent, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: warn ? c.warn : c.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: TextStyle(color: c.faint, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.sub, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}