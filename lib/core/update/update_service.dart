// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE SERVICE
//
// Checks GitHub Releases for a newer version of the app and picks the right
// APK asset for THIS device's architecture.
//
// Flow:
//   1. Read the installed version via package_info_plus.
//   2. GET https://api.github.com/repos/{owner}/{repo}/releases/latest
//   3. Compare semantic versions (major.minor.patch; build number ignored).
//   4. Choose the best-matching .apk asset for the device ABI.
//   5. Return a typed result the UI renders (card state / dialog / snack).
//
// APK SELECTION (smart, 3 passes):
//   - Exactly one .apk asset        -> take it (fat APK, any filename).
//   - Multiple .apk assets          -> pass 1: exact ABI keyword match for
//     this device's bitness; pass 2: exclude assets of the WRONG
//     architecture; pass 3: fallback to the first .apk.
//   This means: split-per-abi releases install the correct slice, while a
//   single universal APK is always downloaded regardless of its name.
//
// BITNESS DETECTION (no Abi enum, no .name):
//   Uses sizeOf<IntPtr>() from dart:ffi — 8 bytes on 64-bit, 4 on 32-bit.
//   This is a core Dart library, compiles on every SDK, and never depends
//   on enum member names that may differ between SDK versions.
//
// Safety guarantees:
//   - A fresh http.Client per check, closed in `finally` (zero leaks).
//   - Hard 8-second timeout: a dead network can never hang the UI.
//   - HTTP 404 (no releases published yet) => upToDate, NOT an error.
//   - Defensive JSON parsing: any malformed payload => failed, never a crash.
//   - The service never throws upward; all failures are typed results.
//   - Failure is classified (noNetwork / httpError / parseError / unknown) so
//     the UI can show an actionable hint ("check internet / try VPN / use
//     RuStore") instead of a generic "failed" message.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' show IntPtr, sizeOf;
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Parsed "latest release" payload from the GitHub API.
class UpdateInfo {
  final String version;
  final String tagName;
  final String? apkDownloadUrl;
  final int? apkSizeBytes;
  final String? releaseNotes;
  final String? htmlUrl;
  final DateTime publishedAt;

  const UpdateInfo({
    required this.version,
    required this.tagName,
    this.apkDownloadUrl,
    this.apkSizeBytes,
    this.releaseNotes,
    this.htmlUrl,
    required this.publishedAt,
  });
}

enum UpdateCheckStatus { upToDate, available, failed }

/// Why a check failed. The UI uses this to pick the right hint text.
enum UpdateFailureKind {
  /// No network path to GitHub at all (offline / DNS / timeout / connection
  /// refused / blocked). The user should check internet or try a VPN.
  noNetwork,

  /// Network worked but GitHub returned a non-2xx/non-404 status (rate
  /// limit, server error, forbidden). Worth retrying later.
  httpError,

  /// GitHub returned 200 but the body was not valid release JSON.
  parseError,

  /// Anything else we could not classify.
  unknown,
}

class UpdateCheckResult {
  final UpdateCheckStatus status;
  final String currentVersion;
  final UpdateInfo? info;
  final String? errorMessage;

  /// Present only when status == failed. Drives the error-dialog copy.
  final UpdateFailureKind? failureKind;

  const UpdateCheckResult({
    required this.status,
    required this.currentVersion,
    this.info,
    this.errorMessage,
    this.failureKind,
  });
}

class UpdateService {
  const UpdateService({
    this.githubOwner = 'Shapak-Apps',
    this.githubRepo = 'K-pri-App-for-phone',
    this.ruStoreUrl = 'https://www.rustore.ru/catalog/app/com.kopri.translator',
  });

  final String githubOwner;
  final String githubRepo;
  final String ruStoreUrl;

  static const Duration _timeout = Duration(seconds: 8);

  /// Filename keywords that identify a 64-bit APK slice.
  static const List<String> _k64 = ['arm64', 'aarch64', 'x86_64', 'x64', '64'];

  /// Filename keywords that identify a 32-bit APK slice.
  static const List<String> _k32 = [
    'armeabi-v7a',
    'armv7',
    'arm32',
    'x86',
    'i386',
    'ia32',
    '32',
  ];

  /// True when running on a 64-bit process.
  ///
  /// Uses the native pointer width: 8 bytes on 64-bit, 4 on 32-bit. This is
  /// the most portable, dependency-free way to detect bitness and never
  /// touches enum member names that vary between SDKs.
  static bool _is64Bit() {
    try {
      return sizeOf<IntPtr>() == 8;
    } catch (_) {
      // Should never happen; assume 64-bit (dominant on modern devices).
      return true;
    }
  }

  /// Full check flow. Never throws; always returns a typed result.
  Future<UpdateCheckResult> checkForUpdates() async {
    final client = http.Client();
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version;

      final response = await client
          .get(
            Uri.https(
              'api.github.com',
              '/repos/$githubOwner/$githubRepo/releases/latest',
            ),
            headers: const {
              'Accept': 'application/vnd.github+json',
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
          failureKind: UpdateFailureKind.httpError,
          errorMessage: 'http_${response.statusCode}',
        );
      }

      final info = _parseRelease(response.body);
      if (info == null) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.failed,
          currentVersion: current,
          failureKind: UpdateFailureKind.parseError,
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
      final kind = _classifyFailure(e);
      return UpdateCheckResult(
        status: UpdateCheckStatus.failed,
        currentVersion: '',
        failureKind: kind,
        errorMessage: e.toString(),
      );
    } finally {
      client.close();
    }
  }

  /// Maps a thrown exception to an UpdateFailureKind.
  static UpdateFailureKind _classifyFailure(Object e) {
    if (e is TimeoutException) return UpdateFailureKind.noNetwork;
    if (e is SocketException) return UpdateFailureKind.noNetwork;
    if (e is http.ClientException) return UpdateFailureKind.noNetwork;
    if (e is HttpException) return UpdateFailureKind.noNetwork;
    if (e is FormatException) return UpdateFailureKind.parseError;
    return UpdateFailureKind.unknown;
  }

  /// Defensive parser: returns null on any structural surprise.
  UpdateInfo? _parseRelease(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] as String?)?.trim() ?? '';
      final version = _stripLeadingV(tagName);
      if (version.isEmpty) return null;

      String? apkUrl;
      int? apkSize;
      final assets = data['assets'];
      if (assets is List) {
        apkUrl = _pickApkUrlForDevice(assets);
        // Extract the exact size of the chosen APK for cache-skip logic.
        if (apkUrl != null) {
          for (final a in assets) {
            if (a is Map<String, dynamic> &&
                a['browser_download_url'] == apkUrl) {
              apkSize = (a['size'] as num?)?.toInt();
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
        apkSizeBytes: apkSize,
        releaseNotes: (data['body'] as String?)?.trim(),
        htmlUrl: data['html_url'] as String?,
        publishedAt: publishedAt,
      );
    } catch (_) {
      return null;
    }
  }

  /// Smart APK picker (see header comment for the 3-pass strategy).
  ///
  /// Returns null when the release has no `.apk` asset at all.
  static String? _pickApkUrlForDevice(List<dynamic> assets) {
    // Collect every .apk asset.
    final apks = <Map<String, dynamic>>[];
    for (final a in assets) {
      if (a is! Map<String, dynamic>) continue;
      final name = (a['name'] as String?) ?? '';
      final url = a['browser_download_url'] as String?;
      if (url == null) continue;
      if (name.toLowerCase().endsWith('.apk')) apks.add(a);
    }
    if (apks.isEmpty) return null;

    // Pass 0: a single APK is universal -> take it regardless of name.
    if (apks.length == 1) {
      return apks[0]['browser_download_url'] as String?;
    }

    final is64 = _is64Bit();
    final preferred = is64 ? _k64 : _k32;
    final wrong = is64 ? _k32 : _k64;

    String? urlOf(Map<String, dynamic> a) =>
        a['browser_download_url'] as String?;
    String nameOf(Map<String, dynamic> a) =>
        ((a['name'] as String?) ?? '').toLowerCase();

    // Pass 1: exact ABI keyword match for this device's bitness.
    for (final a in apks) {
      final n = nameOf(a);
      if (preferred.any(n.contains)) return urlOf(a);
    }

    // Pass 2: no exact match -> avoid the WRONG architecture if possible.
    for (final a in apks) {
      final n = nameOf(a);
      if (!wrong.any(n.contains)) return urlOf(a);
    }

    // Pass 3: heuristics exhausted -> first .apk (better than nothing).
    return urlOf(apks[0]);
  }

  static String _stripLeadingV(String s) =>
      (s.startsWith('v') || s.startsWith('V')) ? s.substring(1) : s;

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
