// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE CARD
//
// The "Check for updates" card embedded in the About screen.
//
// States: idle -> checking -> upToDate | available | failed.
// The card owns its request lifecycle; every setState is mounted-guarded, so
// leaving the screen mid-request can never crash. No timers, no listeners,
// no disposables -> nothing to leak.
//
// On failure, a friendly dialog is shown that guides the user to check
// their internet / try a VPN / open RuStore, with an inline "Try again"
// action that re-runs the check from the same card.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../controllers/app_settings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'update_dialog.dart';
import 'update_downloader.dart';
import 'update_l10n.dart';
import 'update_service.dart';

class UpdateCheckCard extends StatefulWidget {
  const UpdateCheckCard({super.key});

  @override
  State<UpdateCheckCard> createState() => _UpdateCheckCardState();
}

class _UpdateCheckCardState extends State<UpdateCheckCard> {
  static const UpdateService _service = UpdateService();
  static const Color _okGreen = Color(0xFF10B981);

  UpdateCheckResult? _result;
  bool _checking = false;
  String _current = '';

  @override
  void initState() {
    super.initState();
    _readCurrentVersion();
  }

  Future<void> _readCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _current = info.version);
    } catch (_) {
      // PackageInfo unavailable: the card still works, version line hidden.
    }
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _result = null;
    });

    final result = await _service.checkForUpdates();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _result = result;
    });

    final t = UpdateStrings(context.settings.lang.name);

    if (result.status == UpdateCheckStatus.available && result.info != null) {
      await showUpdateDialog(context, result.info!);
      return;
    }

    if (result.status == UpdateCheckStatus.upToDate) {
      showUpdateSnack(context, t.upToDate);
      // Clean up old APK files from previous update attempts.
      // Fire-and-forget: we don't await this, the UI doesn't need to wait.
      UpdateDownloader.cleanApkCache();
      return;
    }

    // Failed: show the guided dialog. If the user taps "Try again" we
    // simply re-run the check; "Open RuStore" is handled by the dialog
    // itself and "Later" just closes it.
    final action = await showUpdateFailedDialog(context);
    if (!mounted) return;
    if (action == UpdateFailedAction.retry) {
      await _check();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = UpdateStrings(context.settings.lang.name);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.surfaceHi, c.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.accent.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.system_update_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.checkUpdates,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _statusLine(c, t),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _checking ? null : _check,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.accent, c.accentDeep]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_checking)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      const SizedBox(width: 10),
                      Text(
                        _checking ? t.checking : t.checkUpdates,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Live status line under the card title.
  Widget _statusLine(AppColors c, UpdateStrings t) {
    if (_checking) {
      return Text(
        t.checking,
        style: AppTheme.caption(color: c.faint, size: 12),
      );
    }
    final res = _result;
    if (res == null) {
      return Text(
        _current.isEmpty ? t.checkUpdatesSub : t.currentVersion('v$_current'),
        style: AppTheme.caption(color: c.faint, size: 12),
      );
    }

    switch (res.status) {
      case UpdateCheckStatus.upToDate:
        return Row(
          children: [
            const Icon(Icons.verified_rounded, color: _okGreen, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.upToDate,
                style: AppTheme.caption(color: _okGreen, size: 12),
              ),
            ),
          ],
        );
      case UpdateCheckStatus.available:
        return Row(
          children: [
            Icon(Icons.arrow_circle_up_rounded, color: c.accent, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${t.available}: v${res.info?.version ?? ''}',
                style: AppTheme.caption(color: c.accent, size: 12),
              ),
            ),
          ],
        );
      case UpdateCheckStatus.failed:
        return Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: c.warn, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.failedSub,
                style: AppTheme.caption(color: c.warn, size: 12),
              ),
            ),
          ],
        );
    }
  }
}
