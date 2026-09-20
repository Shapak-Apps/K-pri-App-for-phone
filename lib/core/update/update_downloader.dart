// ─────────────────────────────────────────────────────────────────────────────
// KÖPRI UPDATE DOWNLOADER
//
// Downloads an APK from a GitHub Releases URL into the app's INTERNAL cache
// with UNLIMITED retry + resume support, reporting progress to the UI.
//
// WHY UNLIMITED RETRY:
//   GitHub asset URLs (objects.githubusercontent.com) aggressively tear down
//   long-lived TCP connections on mobile networks — the symptom is a download
//   that reaches ~5-15% and then dies. Mobile networks are unreliable by
//   nature, so we retry until the download completes or a permanent error
//   occurs (404, auth failure, etc).
//
// Strategy:
//   - No attempt limit; retry forever on transient errors.
//   - Before each attempt we check how many bytes are already on disk.
//   - If > 0, we send `Range: bytes=N-` so GitHub returns only the tail.
//   - Dio writes with FileMode.append so each attempt extends the file.
//   - Transient errors (timeout, reset, DNS, 5xx, connection drop) are
//     retried after exponential backoff (capped at 30s).
//   - Permanent errors (4xx except 408/429, bad certificate) bail out
//     immediately to avoid infinite loops.
//   - STALE DETECTION: if 3 consecutive retries make zero progress, treat
//     as permanent failure (server is serving empty responses).
//   - Progress is cumulative (alreadyOnDisk + newlyReceived) / total so the
//     UI bar never jumps backwards.
//
// CACHE-SKIP (expectedSize):
//   If [expectedSize] is provided and a file already exists in cache with
//   exactly that size, we skip the download entirely and return completed.
//   This removes the "download again after enabling unknown sources" loop.
//
// PATH CONTRACT (must match UpdateInstaller):
//   The target directory is getTemporaryDirectory() (internal cache on
//   Android), which res/xml/file_paths.xml exposes under "apk_cache".
//
// Never throws upward: every failure is returned as a typed
// UpdateDownloadResult.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Called on every progress tick. [fraction] is in 0.0..1.0 and already
/// includes bytes downloaded in previous attempts (cumulative).
typedef ProgressCallback =
    void Function(double fraction, int received, int total);

enum DownloadStatus { completed, cancelled, failed }

class UpdateDownloadResult {
  final DownloadStatus status;

  /// Absolute path to the downloaded APK (only set when status == completed).
  final String? apkPath;

  /// Human-readable reason for failure (only set when status == failed).
  final String? error;

  const UpdateDownloadResult._({
    required this.status,
    this.apkPath,
    this.error,
  });

  const UpdateDownloadResult.completed(String path)
    : this._(status: DownloadStatus.completed, apkPath: path);
  const UpdateDownloadResult.cancelled()
    : this._(status: DownloadStatus.cancelled);
  const UpdateDownloadResult.failed(String error)
    : this._(status: DownloadStatus.failed, error: error);
}

class DownloadHandle {
  final CancelToken _token;
  DownloadHandle._(this._token);

  void cancel() {
    if (!_token.isCancelled) _token.cancel('user_cancelled');
  }

  bool get isCancelled => _token.isCancelled;
}

class UpdateDownloader {
  UpdateDownloader({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Per-attempt timeouts. Generous on receive — we expect long downloads.
  static const Duration _sendTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(minutes: 30);
  static const Duration _connectTimeout = Duration(seconds: 20);

  /// Maximum backoff delay between retries (capped exponential).
  static const Duration _maxBackoff = Duration(seconds: 30);

  /// If we make this many consecutive retries without downloading a single
  /// new byte, treat as permanent failure (server is broken, not network).
  static const int _staleRetryThreshold = 3;

  /// Removes all .apk files left over from previous update downloads.
  /// Call on app startup or after a successful "up to date" check.
  ///
  /// This keeps the cache clean: after a successful install, the next
  /// "Check for updates" will return upToDate (since the new version is
  /// already installed), triggering this cleanup automatically.
  static Future<void> cleanApkCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
          await _safeDelete(entity);
        }
      }
    } catch (_) {}
  }

  Future<UpdateDownloadResult> start({
    required String url,
    int? expectedSize,
    ProgressCallback? onProgress,
    required void Function(DownloadHandle handle) onHandleReady,
  }) async {
    final cancelToken = CancelToken();
    onHandleReady(DownloadHandle._(cancelToken));

    File? targetFile;
    int totalBytes = 0;
    int attemptCount = 0;
    int lastBytesOnDisk = 0;
    int staleRetryCount = 0;

    try {
      final dir = await getTemporaryDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);

      final fileName = _fileNameFromUrl(url);
      targetFile = File('${dir.path}${Platform.pathSeparator}$fileName');

      // Cache-skip: if a previous download already produced a complete file
      // (size matches the GitHub asset), reuse it — NO re-download. This is
      // what removes the "download again after enabling permission" loop.
      if (expectedSize != null && expectedSize > 0) {
        final existing = await _existingBytes(targetFile);
        if (existing == expectedSize) {
          return UpdateDownloadResult.completed(targetFile.path);
        }
        // Partial / wrong-size leftover: start clean.
        if (existing > 0) await _safeDelete(targetFile);
      }

      // Retry loop: unlimited attempts until success, cancel, or permanent error.
      while (true) {
        if (cancelToken.isCancelled) {
          await _safeDelete(targetFile);
          return const UpdateDownloadResult.cancelled();
        }

        attemptCount++;
        final alreadyOnDisk = await _existingBytes(targetFile);

        // Stale detection: if we've retried N times without progress, bail.
        if (alreadyOnDisk == lastBytesOnDisk && attemptCount > 1) {
          staleRetryCount++;
          if (staleRetryCount >= _staleRetryThreshold) {
            await _safeDelete(targetFile);
            return const UpdateDownloadResult.failed(
              'no_progress_after_retries',
            );
          }
        } else {
          staleRetryCount = 0;
          lastBytesOnDisk = alreadyOnDisk;
        }

        try {
          final ok = await _attemptDownload(
            url: url,
            targetFile: targetFile,
            alreadyOnDisk: alreadyOnDisk,
            totalBytesRef: (t) => totalBytes = t,
            cancelToken: cancelToken,
            onProgress: (received, total) {
              final totalForUi = total > 0 ? total : totalBytes;
              final cumulative = alreadyOnDisk + received;
              final frac = totalForUi > 0 ? cumulative / totalForUi : 0.0;
              onProgress?.call(frac.clamp(0.0, 1.0), cumulative, totalForUi);
            },
          );

          if (cancelToken.isCancelled) {
            await _safeDelete(targetFile);
            return const UpdateDownloadResult.cancelled();
          }
          if (ok) {
            return UpdateDownloadResult.completed(targetFile.path);
          }
          // Not ok but not thrown -> treat as transient, retry.
        } on DioException catch (e) {
          if (cancelToken.isCancelled || CancelToken.isCancel(e)) {
            await _safeDelete(targetFile);
            return const UpdateDownloadResult.cancelled();
          }
          // Permanent errors: do NOT retry.
          if (_isPermanentDioError(e)) {
            await _safeDelete(targetFile);
            return UpdateDownloadResult.failed(_describeDioError(e));
          }
          // Transient -> fall through to backoff + retry.
        } catch (e) {
          // Anything else (FileSystemException, unexpected) -> bail.
          await _safeDelete(targetFile);
          return UpdateDownloadResult.failed(e.toString());
        }

        // Exponential backoff: 1s, 2s, 4s, 8s, 16s, then cap at 30s.
        final backoffMs = (1000 * (1 << (attemptCount - 1))).clamp(
          1000,
          _maxBackoff.inMilliseconds,
        );
        await Future.delayed(Duration(milliseconds: backoffMs));
      }
    } catch (e) {
      await _safeDelete(targetFile);
      return UpdateDownloadResult.failed(e.toString());
    }
  }

  /// One download attempt. Returns true if the file is complete, false if
  /// the attempt ended early for a transient reason (caller will retry).
  Future<bool> _attemptDownload({
    required String url,
    required File targetFile,
    required int alreadyOnDisk,
    required void Function(int total) totalBytesRef,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    final headers = <String, dynamic>{
      'User-Agent': 'KopriApp',
      'Accept': '*/*',
    };
    if (alreadyOnDisk > 0) {
      headers['Range'] = 'bytes=$alreadyOnDisk-';
    }

    final response = await _dio.download(
      url,
      targetFile.path,
      cancelToken: cancelToken,
      deleteOnError: false,
      fileAccessMode: FileAccessMode.append,
      options: Options(
        headers: headers,
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
      ),
      lengthHeader: Headers.contentLengthHeader,
      onReceiveProgress: (received, total) {
        if (total > 0) totalBytesRef(total + alreadyOnDisk);
        onProgress(received, total > 0 ? total + alreadyOnDisk : 0);
      },
    );

    if (cancelToken.isCancelled) return false;

    final code = response.statusCode ?? 0;
    final sizeOk = await targetFile.exists() && await targetFile.length() > 0;
    if (code >= 200 && code < 300 && sizeOk) {
      return true;
    }
    return false;
  }

  static Future<int> _existingBytes(File f) async {
    try {
      if (await f.exists()) return await f.length();
    } catch (_) {}
    return 0;
  }

  /// Permanent errors (auth, not found, malformed URL) should not be retried.
  static bool _isPermanentDioError(DioException e) {
    final r = e.response;
    if (r != null) {
      final c = r.statusCode ?? 0;
      if (c >= 400 && c < 500 && c != 408 && c != 429) return true;
    }
    if (e.type == DioExceptionType.badCertificate) return true;
    return false;
  }

  static String _describeDioError(DioException e) {
    final r = e.response;
    if (r != null) return 'http_${r.statusCode}';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'connect_timeout';
      case DioExceptionType.sendTimeout:
        return 'send_timeout';
      case DioExceptionType.receiveTimeout:
        return 'receive_timeout';
      case DioExceptionType.connectionError:
        return 'no_network';
      case DioExceptionType.badCertificate:
        return 'bad_certificate';
      default:
        return e.message ?? e.type.name;
    }
  }

  static String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (last.isNotEmpty && last.toLowerCase().endsWith('.apk')) {
        return last;
      }
    } catch (_) {}
    return 'update.apk';
  }

  static Future<void> _safeDelete(File? f) async {
    if (f == null) return;
    try {
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
