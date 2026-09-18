import 'package:flutter/services.dart';

/// Dart side of the "kopri/apk" bridge.
///
/// The native counterpart is registered in `MainActivity.kt`
/// (`configureFlutterEngine` → `MethodChannel(..., "kopri/apk")`).
///
/// The channel is name-based: the Kotlin handler only matches the channel
/// name and method names, so the Dart declaration may live in any file.
/// Keeping it here provides a single source of truth for the name string.
///
/// Supported methods (see MainActivity.kt):
///  - `getApkPath`             → path to the installed APK
///  - `getCacheDir`            → app cache directory
///  - `canDrawOverlays`        → SYSTEM_ALERT_WINDOW permission state
///  - `openOverlaySettings`    → opens the overlay-permission settings page
///  - `startClipboard`         → starts ClipboardService (args: source/target)
///  - `stopClipboard`          → stops ClipboardService
///  - `isClipboardRunning`     → current service state
///  - `setIgnoreNextClipboard` → makes the bubble skip the next copy
const MethodChannel kApkChannel = MethodChannel('kopri/apk');
