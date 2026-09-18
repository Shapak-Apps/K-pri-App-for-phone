import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controllers/app_settings_controller.dart';
import '../../../core/native/apk_channel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/linkage_language_picker.dart';
import '../../camera/data/camera_repository.dart';
import '../../history/data/history_repository.dart';

/// Floating snackbar shared by every settings flow.
void showSettingsSnack(
  BuildContext context,
  String text, {
  bool warn = false,
}) => ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(text),
    backgroundColor: warn ? context.c.warn : context.c.accent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
);

/// Modal yes/no confirmation used by destructive actions.
Future<bool> askSettingsConfirm(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final c = ctx.c;
      final l10n = ctx.settings.l10n;
      return AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: TextStyle(
            color: c.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.t('cancel'),
              style: TextStyle(color: c.sub, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: c.warn,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.t('confirm'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      );
    },
  );
  return ok == true;
}

/// Language picker for the default source/target tiles.
Future<void> pickSettingsLanguage(
  BuildContext context,
  bool includeAuto,
  String current,
  ValueChanged<String> on,
) async {
  final picked = await LinkageLanguagePicker.show(
    context,
    currentCode: current,
    includeAuto: includeAuto,
  );
  if (picked != null && picked != current) on(picked);
}

/// Shares the installed APK via the system share sheet (Android only).
Future<void> shareAppApk(BuildContext context) async {
  final l10n = context.settings.l10n;
  if (!Platform.isAndroid) {
    if (context.mounted)
      showSettingsSnack(context, l10n.t('share_unavailable'));
    return;
  }
  try {
    final apk = await kApkChannel.invokeMethod<String>('getApkPath');
    final cache = await kApkChannel.invokeMethod<String>('getCacheDir');
    if (apk == null || cache == null || apk.isEmpty) {
      if (context.mounted) {
        showSettingsSnack(context, l10n.t('apk_not_found'));
      }
      return;
    }
    final dest = File('$cache/Kopri.apk');
    await File(apk).copy(dest.path);
    await Share.shareXFiles(
      [XFile(dest.path)],
      subject: 'Köpri',
      text: 'Köpri — ähli dillerde terjimeçi 🌉',
    );
  } catch (e) {
    if (context.mounted) {
      showSettingsSnack(context, '${l10n.t('share_failed')}: $e');
    }
  }
}

/// Shows a non-dismissable loading overlay; returns its close callback.
void Function() _showBlockingLoading(BuildContext context, String label) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.c.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.c.accent),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  color: context.c.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return () {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  };
}

/// Exports history as a JSON file (Android share) with clipboard fallback.
Future<void> exportHistoryFile(
  BuildContext context,
  HistoryRepository repo,
) async {
  final l10n = context.settings.l10n;
  final close = _showBlockingLoading(context, l10n.t('export_history'));
  String json = '';
  try {
    json = await repo.exportJson();
  } catch (e) {
    close();
    if (context.mounted) {
      showSettingsSnack(context, l10n.t('export_failed'), warn: true);
    }
    return;
  }
  bool shared = false;
  try {
    if (Platform.isAndroid) {
      final cache = await kApkChannel.invokeMethod<String>('getCacheDir');
      if (cache != null && cache.isNotEmpty) {
        final file = File('$cache/kopri_history.json');
        await file.writeAsString(json);
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Köpri',
          text: 'Köpri — history',
        );
        shared = true;
      }
    }
  } catch (_) {}
  if (!shared) {
    try {
      await Clipboard.setData(ClipboardData(text: json));
      shared = true;
    } catch (_) {}
  }
  close();
  if (context.mounted) {
    showSettingsSnack(
      context,
      shared ? l10n.t('history_exported') : l10n.t('export_failed'),
      warn: !shared,
    );
  }
}

/// Imports history JSON from the system clipboard.
Future<void> importHistoryClipboard(
  BuildContext context,
  HistoryRepository repo,
) async {
  final l10n = context.settings.l10n;
  final raw = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
  if (raw == null || raw.trim().isEmpty) {
    if (context.mounted)
      showSettingsSnack(context, l10n.t('no_data_clipboard'));
    return;
  }
  if (!await askSettingsConfirm(context, l10n.t('import_history'))) return;
  if (!context.mounted) return;
  final close = _showBlockingLoading(context, l10n.t('import_history'));
  try {
    final n = await repo.importJson(raw);
    close();
    if (context.mounted) {
      showSettingsSnack(context, '${l10n.t('history_imported')} · $n');
    }
  } on PlatformException catch (e) {
    close();
    final msg = e.message ?? l10n.t('invalid_json');
    if (context.mounted) {
      showSettingsSnack(
        context,
        '${l10n.t('import_failed')}: $msg',
        warn: true,
      );
    }
  } catch (e) {
    close();
    if (context.mounted) {
      showSettingsSnack(context, '${l10n.t('import_failed')}: $e', warn: true);
    }
  }
}

/// Danger-zone actions ──────────────────────────────────────────────

Future<void> clearHistoryAction(
  BuildContext context,
  HistoryRepository repo,
) async {
  final l10n = context.settings.l10n;
  if (!await askSettingsConfirm(context, l10n.t('clear_history'))) return;
  final n = await repo.clear();
  if (context.mounted) showSettingsSnack(context, '${l10n.t('cleared')} · $n');
}

Future<void> clearFavoritesAction(
  BuildContext context,
  HistoryRepository repo,
) async {
  final l10n = context.settings.l10n;
  if (!await askSettingsConfirm(context, l10n.t('clear_favorites'))) return;
  final n = await repo.clearFavorites();
  if (context.mounted) {
    showSettingsSnack(context, '${l10n.t('removed_stars')} · $n');
  }
}

Future<void> clearAllAction(
  BuildContext context,
  HistoryRepository repo,
) async {
  final l10n = context.settings.l10n;
  if (!await askSettingsConfirm(context, l10n.t('clear_all'))) return;
  final n = await repo.clear();
  if (context.mounted) showSettingsSnack(context, '${l10n.t('cleared')} · $n');
}

Future<void> clearPhotosAction(BuildContext context) async {
  final l10n = context.settings.l10n;
  if (!await askSettingsConfirm(context, l10n.t('clear_photos'))) return;
  final n = await CameraRepository.instance.clearAll();
  if (context.mounted) {
    showSettingsSnack(context, '${l10n.t('photos_cleared')} · $n');
  }
}
