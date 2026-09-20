// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE DIALOG
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_settings_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/github_logo.dart';
import 'update_downloader.dart';
import 'update_installer.dart';
import 'update_l10n.dart';
import 'update_service.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Future<void> launchExternal(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri);
    }
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(url),
        backgroundColor: context.c.warn,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

void showUpdateSnack(
  BuildContext context,
  String message, {
  bool warn = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: warn ? context.c.warn : context.c.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

String _stripMarkdown(String s) {
  try {
    var out = s.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    final lines = out.split('\n');
    final buf = StringBuffer();
    for (var raw in lines) {
      var line = raw;
      line = line.replaceFirst(RegExp(r'^\s{0,3}#{1,6}\s+'), '');
      line = line.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]*\)'), r'$1');
      line = line.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
      line = line.replaceAll(RegExp(r'__(.+?)__'), r'$1');
      line = line.replaceAll(RegExp(r'(?<![\w])\*([^*\n]+?)\*(?![\w])'), r'$1');
      line = line.replaceAll(RegExp(r'(?<![\w])_([^_\n]+?)_(?![\w])'), r'$1');
      line = line.replaceAll(RegExp(r'`([^`\n]+?)`'), r'$1');
      line = line.replaceFirst(RegExp(r'^\s*[-*+]\s+'), '• ');
      buf.writeln(line);
    }
    var text = buf.toString();
    while (text.endsWith('\n\n')) {
      text = text.substring(0, text.length - 1);
    }
    return text.trim();
  } catch (_) {
    return s;
  }
}

// ─── Lifecycle waiter ────────────────────────────────────────────────────────

/// Fires a [Future] exactly once when the app returns to [AppLifecycleState.resumed].
/// Must be [dispose]d when no longer needed (removes the observer).
class _AppResumeWaiter extends WidgetsBindingObserver {
  final _completer = Completer<void>();

  _AppResumeWaiter() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_completer.isCompleted) {
      _completer.complete();
    }
  }

  Future<void> get future => _completer.future;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_completer.isCompleted) _completer.complete();
  }
}

// ─── Permission request dialog ───────────────────────────────────────────────

/// Shows a clear explanation dialog, opens the per-app "Install unknown apps"
/// Settings screen, waits for the user to return, then re-checks permission.
///
/// Returns [true] iff [installer.canInstallPackages()] is true on return.
Future<bool> _requestInstallPermission(
  BuildContext context,
  UpdateInstaller installer,
  UpdateStrings t,
  AppColors c,
) async {
  if (!context.mounted) return false;

  final shouldOpen = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: c.accent.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.accent, c.accentDeep],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.permissionTitle,
                          style: TextStyle(
                            color: c.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.permissionOnce,
                          style: TextStyle(color: c.faint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: Icon(Icons.close_rounded, color: c.faint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                t.permissionBody,
                style: TextStyle(color: c.sub, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 18),
              _DialogButton(
                label: t.openSettings,
                icon: Icons.settings_rounded,
                gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                foreground: Colors.white,
                onTap: () => Navigator.pop(ctx, true),
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: t.later,
                icon: Icons.schedule_rounded,
                foreground: c.sub,
                onTap: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (shouldOpen != true || !context.mounted) return false;

  // Open per-app "Install unknown apps" toggle.
  await installer.openUnknownSourcesSettings();

  // Wait until the user comes back to our app.
  final waiter = _AppResumeWaiter();
  await waiter.future;
  waiter.dispose();

  if (!context.mounted) return false;
  return installer.canInstallPackages();
}

// ─── "Update available" dialog ───────────────────────────────────────────────

Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) async {
  final c = context.c;
  final t = UpdateStrings(context.settings.lang.name);
  final rustoreUrl = const UpdateService().ruStoreUrl;

  final cleanedNotes = info.releaseNotes == null || info.releaseNotes!.isEmpty
      ? null
      : _stripMarkdown(info.releaseNotes!);

  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: c.accent.withValues(alpha: 0.25),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.accent, c.accentDeep],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.available,
                          style: TextStyle(
                            color: c.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${info.version}',
                          style: TextStyle(
                            color: c.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close_rounded, color: c.faint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                t.availableMsg(info.version),
                style: TextStyle(color: c.sub, height: 1.5, fontSize: 14),
              ),
              if (cleanedNotes != null && cleanedNotes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  t.changelog,
                  style: TextStyle(
                    color: c.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.surfaceHi,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.line),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        cleanedNotes,
                        style: TextStyle(
                          color: c.sub,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _DialogButton(
                label: t.downloadApk,
                useGithubLogo: true,
                gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                foreground: Colors.white,
                enabled: info.apkDownloadUrl != null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await _downloadAndInstallInApp(context, info);
                },
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: t.rustore,
                icon: Icons.storefront_rounded,
                foreground: c.accent,
                borderColor: c.accent.withValues(alpha: 0.45),
                onTap: () {
                  Navigator.pop(ctx);
                  launchExternal(context, rustoreUrl);
                },
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: t.later,
                icon: Icons.schedule_rounded,
                foreground: c.sub,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── Download + install flow ─────────────────────────────────────────────────

/// [attemptCount] guards against infinite recursion when permission is
/// granted, then revoked, then granted again. After 2 failed permission
/// attempts we bail out with an error snack.
Future<void> _downloadAndInstallInApp(
  BuildContext context,
  UpdateInfo info, [
  int attemptCount = 0,
]) async {
  final c = context.c;
  final t = UpdateStrings(context.settings.lang.name);
  final url = info.apkDownloadUrl!;
  final installer = UpdateInstaller();

  // ── 1. Pre-flight permission check ───────────────────────────────────────
  if (!await installer.canInstallPackages()) {
    if (!context.mounted) return;
    final granted = await _requestInstallPermission(context, installer, t, c);
    if (!context.mounted || !granted) return;
  }

  // ── 2. Progress dialog + download ────────────────────────────────────────
  final notifier = ValueNotifier<_DownloadUiState>(
    const _DownloadUiState(fraction: 0.0, phase: _Phase.downloading),
  );
  DownloadHandle? handle;

  showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => ValueListenableBuilder<_DownloadUiState>(
      valueListenable: notifier,
      builder: (ctx, state, _) {
        final pct = (state.fraction * 100).clamp(0.0, 100.0);
        final isInstalling = state.phase == _Phase.installing;
        final isDone = state.phase == _Phase.done;
        return PopScope(
          canPop: isDone,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 48,
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: c.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [c.accent, c.accentDeep],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInstalling
                              ? Icons.settings_applications_rounded
                              : Icons.download_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isInstalling ? t.installing : t.downloading,
                          style: TextStyle(
                            color: c.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: isDone ? 1.0 : state.fraction,
                      minHeight: 8,
                      backgroundColor: c.surfaceHi,
                      valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isInstalling ? t.installing : '${pct.toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.sub,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!isDone)
                    _DialogButton(
                      label: t.cancel,
                      icon: Icons.close_rounded,
                      foreground: c.sub,
                      borderColor: c.line,
                      onTap: () {
                        handle?.cancel();
                        Navigator.pop(ctx, false);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  final downloader = UpdateDownloader();
  final result = await downloader.start(
    url: url,
    expectedSize: info.apkSizeBytes,
    onHandleReady: (h) => handle = h,
    onProgress: (fraction, _, __) {
      notifier.value = _DownloadUiState(
        fraction: fraction,
        phase: _Phase.downloading,
      );
    },
  );

  // ── 3. Handle download result ─────────────────────────────────────────────
  switch (result.status) {
    case DownloadStatus.cancelled:
      notifier.dispose();
      return;

    case DownloadStatus.failed:
      if (context.mounted) Navigator.of(context).pop(false);
      notifier.dispose();
      if (context.mounted)
        showUpdateSnack(context, t.downloadFailed, warn: true);
      return;

    case DownloadStatus.completed:
      notifier.value = const _DownloadUiState(
        fraction: 1.0,
        phase: _Phase.installing,
      );

      final installResult = await installer.install(result.apkPath!);

      if (!context.mounted) {
        notifier.dispose();
        return;
      }

      switch (installResult) {
        case InstallResult.launched:
          notifier.value = const _DownloadUiState(
            fraction: 1.0,
            phase: _Phase.done,
          );
          await Future.delayed(const Duration(milliseconds: 400));
          if (context.mounted) Navigator.of(context).pop(true);
          notifier.dispose();
          return;

        case InstallResult.needsPermission:
          // Race condition: permission was revoked between pre-check and install.
          // Guard against infinite recursion.
          if (attemptCount >= 2) {
            if (context.mounted) Navigator.of(context).pop(false);
            notifier.dispose();
            if (context.mounted)
              showUpdateSnack(context, t.downloadFailed, warn: true);
            return;
          }
          if (context.mounted) Navigator.of(context).pop(false);
          notifier.dispose();
          if (!context.mounted) return;
          final granted = await _requestInstallPermission(
            context,
            installer,
            t,
            c,
          );
          if (!context.mounted || !granted) return;
          // Retry — APK is still in cache, download will be instant.
          await _downloadAndInstallInApp(context, info, attemptCount + 1);
          return;

        case InstallResult.fallbackOpened:
          notifier.value = const _DownloadUiState(
            fraction: 1.0,
            phase: _Phase.done,
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            Navigator.of(context).pop(true);
            showUpdateSnack(context, t.tapFileToInstall, warn: true);
          }
          notifier.dispose();
          return;

        case InstallResult.noInstaller:
        case InstallResult.error:
          if (context.mounted) Navigator.of(context).pop(false);
          notifier.dispose();
          if (context.mounted)
            showUpdateSnack(context, t.downloadFailed, warn: true);
          return;
      }
  }
}

enum _Phase { downloading, installing, done }

class _DownloadUiState {
  final double fraction;
  final _Phase phase;
  const _DownloadUiState({required this.fraction, required this.phase});
}

// ─── "Can't reach GitHub" dialog ─────────────────────────────────────────────

enum UpdateFailedAction { dismissed, openRustore, retry }

Future<UpdateFailedAction> showUpdateFailedDialog(BuildContext context) async {
  final c = context.c;
  final t = UpdateStrings(context.settings.lang.name);
  final rustoreUrl = const UpdateService().ruStoreUrl;

  final result = await showDialog<UpdateFailedAction>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.warn.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: c.warn.withValues(alpha: 0.20),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.warn, c.warn.withValues(alpha: 0.75)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.warn.withValues(alpha: 0.40),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      t.networkErrorTitle,
                      style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(ctx, UpdateFailedAction.dismissed),
                    icon: Icon(Icons.close_rounded, color: c.faint, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                t.networkErrorBody,
                style: TextStyle(color: c.sub, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 18),
              _DialogButton(
                label: t.openRustore,
                icon: Icons.storefront_rounded,
                gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                foreground: Colors.white,
                onTap: () {
                  Navigator.pop(ctx, UpdateFailedAction.openRustore);
                  launchExternal(context, rustoreUrl);
                },
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: t.tryAgain,
                icon: Icons.refresh_rounded,
                foreground: c.accent,
                borderColor: c.accent.withValues(alpha: 0.45),
                onTap: () => Navigator.pop(ctx, UpdateFailedAction.retry),
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: t.later,
                icon: Icons.schedule_rounded,
                foreground: c.sub,
                onTap: () => Navigator.pop(ctx, UpdateFailedAction.dismissed),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? UpdateFailedAction.dismissed;
}

// ─── Shared button widget ─────────────────────────────────────────────────────

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool useGithubLogo;
  final Color foreground;
  final Gradient? gradient;
  final Color? borderColor;
  final bool enabled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.foreground,
    required this.onTap,
    this.icon,
    this.useGithubLogo = false,
    this.gradient,
    this.borderColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? foreground : foreground.withValues(alpha: 0.4);
    final Widget leading = useGithubLogo
        ? GithubLogo(size: 18, color: fg)
        : (icon != null
              ? Icon(icon, color: fg, size: 18)
              : const SizedBox.shrink());
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: enabled ? gradient : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor ?? Colors.transparent,
                width: 1.2,
              ),
              boxShadow: gradient != null && enabled
                  ? [
                      BoxShadow(
                        color: foreground.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
