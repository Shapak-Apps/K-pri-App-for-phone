// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE DIALOG
//
// The "update available" dialog shown from the About-screen update card.
// Offers three actions:
//   1. Download the signed APK straight from GitHub Releases (browser).
//   2. Open the app page in RuStore.
//   3. Postpone.
//
// Every external launch uses externalApplication mode with a graceful
// in-app-browser fallback; failures surface as a snackbar, never a crash.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_settings_controller.dart';
import '../theme/app_colors.dart';
import 'update_l10n.dart';
import 'update_service.dart';

/// Opens a URL in an external browser; falls back to in-app; snackbar on fail.
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

/// Small floating snackbar helper for update statuses.
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

/// Shows the update dialog. Resolves when the user closes it.
Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) async {
  final c = context.c;
  final t = UpdateStrings(context.settings.lang.name);
  final rustoreUrl = const UpdateService().ruStoreUrl;

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
              if (info.releaseNotes != null &&
                  info.releaseNotes!.isNotEmpty) ...[
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
                        info.releaseNotes!,
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
                icon: Icons.download_rounded,
                gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                foreground: Colors.white,
                enabled: info.apkDownloadUrl != null,
                onTap: () {
                  Navigator.pop(ctx);
                  launchExternal(context, info.apkDownloadUrl!);
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

/// Full-width dialog action button (gradient / outlined / ghost).
class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Gradient? gradient;
  final Color? borderColor;
  final bool enabled;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.onTap,
    this.gradient,
    this.borderColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? foreground : foreground.withValues(alpha: 0.4);
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
                Icon(icon, color: fg, size: 18),
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
