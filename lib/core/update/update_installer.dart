// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE INSTALLER
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum InstallResult {
  launched,
  needsPermission,
  fallbackOpened,
  noInstaller,
  error,
}

class UpdateInstaller {
  static const MethodChannel _channel = MethodChannel('kopri/updates');

  Future<bool> canInstallPackages() async {
    try {
      final ok = await _channel.invokeMethod<bool>('canInstallPackages');
      return ok ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> openUnknownSourcesSettings() async {
    try {
      await _channel.invokeMethod<bool>('openUnknownSourcesSettings');
    } catch (_) {
      try {
        await AndroidIntent(
          action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        ).launch();
      } catch (_) {}
    }
  }

  /// Launches the system installer for the APK at [apkPath].
  ///
  /// Returns [InstallResult.needsPermission] if the OS won't allow installs
  /// from this app — the CALLER is responsible for guiding the user to
  /// Settings (never this method: it can't await the user's return).
  Future<InstallResult> install(String apkPath) async {
    try {
      final file = File(apkPath);
      if (!await file.exists()) return InstallResult.error;
      if (await file.length() == 0) return InstallResult.error;

      // Just check; the caller owns the permission UX.
      if (!await canInstallPackages()) {
        return InstallResult.needsPermission;
      }

      final info = await PackageInfo.fromPlatform();
      final authority = '${info.packageName}.fileprovider';
      final uri = _buildFileProviderUri(authority, file);

      final launched = await _tryInstallIntent(uri);
      if (launched) return InstallResult.launched;

      final opened = await _fallbackOpenApk(file, authority);
      return opened ? InstallResult.fallbackOpened : InstallResult.noInstaller;
    } catch (_) {
      return InstallResult.error;
    }
  }

  Future<bool> _tryInstallIntent(String uri) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: uri,
        type: 'application/vnd.android.package-archive',
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_GRANT_READ_URI_PERMISSION,
        ],
      );
      final canResolve = await intent.canResolveActivity();
      if (canResolve != true) return false;
      await intent.launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _fallbackOpenApk(File file, String authority) async {
    final contentUri = _buildFileProviderUri(authority, file);
    try {
      final ok = await launchUrl(
        Uri.parse(contentUri),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return true;
    } catch (_) {}
    try {
      final ok = await launchUrl(
        Uri.file(file.absolute.path),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return true;
    } catch (_) {}
    return false;
  }

  String _buildFileProviderUri(String authority, File file) {
    final segments = file.uri.pathSegments.where((s) => s.isNotEmpty);
    final name = segments.isEmpty ? 'update.apk' : segments.last;
    return 'content://$authority/apk_cache/${Uri.encodeComponent(name)}';
  }
}
