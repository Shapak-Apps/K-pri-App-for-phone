// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE SERVICE
//
// Checks GitHub Releases for a newer version of the app.
//
// Flow:
//   1. Read the installed version via package_info_plus.
//   2. GET https://api.github.com/repos/{owner}/{repo}/releases/latest
//   3. Compare semantic versions (major.minor.patch; build number ignored).
//   4. Return a typed result the UI renders (card state / dialog / snack).
//
// Safety guarantees:
//   - A fresh http.Client per check, closed in `finally` (zero leaks).
//   - Hard 8-second timeout: a dead network can never hang the UI.
//   - HTTP 404 (no releases published yet) => upToDate, NOT an error.
//   - Defensive JSON parsing: any malformed payload => failed, never a crash.
//   - The service never throws upward; all failures are typed results.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Parsed "latest release" payload from the GitHub API.
class UpdateInfo {
  final String version; // "1.0.3" (tag without leading "v")
  final String tagName; // "v1.0.3" as published
  final String? apkDownloadUrl; // direct .apk asset link, if attached
  final String? releaseNotes; // release body (changelog)
  final String? htmlUrl; // browser link to the release page
  final DateTime publishedAt;

  const UpdateInfo({
    required this.version,
    required this.tagName,
    this.apkDownloadUrl,
    this.releaseNotes,
    this.htmlUrl,
    required this.publishedAt,
  });
}

enum UpdateCheckStatus { upToDate, available, failed }

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final String currentVersion;
  final UpdateInfo? info;
  final String? errorMessage;

  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.info,
    this.errorMessage,
  });
}

class UpdateService {
  const UpdateService({
    this.githubOwner = 'Shapak-Apps',
    this.githubRepo = 'K-pri-App-for-phone',
    this.ruStoreUrl =
        'https://www.rustore.ru/catalog/apps/com.kopri.translator',
  });

  final String githubOwner;
  final String githubRepo;
  final String ruStoreUrl;

  static const Duration _timeout = Duration(seconds: 8);

  /// Full check flow. Never throws; always returns a typed result.
  Future<UpdateCheckResult> checkForUpdates() async {
    final client = http.Client();
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version; // e.g. "1.0.2"

      final response = await client
          .get(
            Uri.https(
              'api.github.com',
              '/repos/$githubOwner/$githubRepo/releases/latest',
            ),
            headers: const {
              'Accept': 'application/vnd.github+json',
              // GitHub rejects requests without a User-Agent.
              'User-Agent': 'KopriApp',
            },
          )
          .timeout(_timeout);

      // No releases published yet -> nothing to update to.
      if (response.statusCode == 404) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.upToDate,
          currentVersion: current,
        );
      }
      if (response.statusCode != 200) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.failed,
          currentVersion: current,
          errorMessage: 'http_${response.statusCode}',
        );
      }

      final info = _parseRelease(response.body);
      if (info == null) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.failed,
          currentVersion: current,
          errorMessage: 'bad_payload',
        );
      }

      if (_isNewer(info.version, current)) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.available,
          currentVersion: current,
          info: info,
        );
      }
      return UpdateCheckResult(
        status: UpdateCheckStatus.upToDate,
        currentVersion: current,
        info: info,
      );
    } catch (e) {
      // Network down, DNS failure, timeout, JSON error: swallow, type it.
      return UpdateCheckResult(
        status: UpdateCheckStatus.failed,
        currentVersion: '',
        errorMessage: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  /// Defensive parser: returns null on any structural surprise.
  UpdateInfo? _parseRelease(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String?)?.trim() ?? '';
      final version = _stripLeadingV(tagName);
      if (version.isEmpty) return null;

      String? apkUrl;
      final assets = data['assets'];
      if (assets is List) {
        for (final asset in assets) {
          if (asset is Map<String, dynamic>) {
            final name = (asset['name'] as String?) ?? '';
            if (name.toLowerCase().endsWith('.apk')) {
              apkUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }
      }

      DateTime publishedAt;
      try {
        publishedAt = DateTime.parse(
          (data['published_at'] as String?) ?? '',
        ).toLocal();
      } catch (_) {
        publishedAt = DateTime.now();
      }

      return UpdateInfo(
        version: version,
        tagName: tagName,
        apkDownloadUrl: apkUrl,
        releaseNotes: (data['body'] as String?)?.trim(),
        htmlUrl: data['html_url'] as String?,
        publishedAt: publishedAt,
      );
    } catch (_) {
      return null;
    }
  }

  static String _stripLeadingV(String s) =>
      (s.startsWith('v') || s.startsWith('V')) ? s.substring(1) : s;

  /// True when [latest] is strictly newer than [current].
  /// Malformed segments are treated as 0 (defensive).
  static bool _isNewer(String latest, String current) {
    final a = _parseVersion(latest);
    final b = _parseVersion(current);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av > bv) return true;
      if (av < bv) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String v) {
    final out = <int>[];
    for (final part in v.split(RegExp(r'[.\-+]'))) {
      final n = int.tryParse(part);
      if (n != null) out.add(n);
    }
    return out;
  }
}
