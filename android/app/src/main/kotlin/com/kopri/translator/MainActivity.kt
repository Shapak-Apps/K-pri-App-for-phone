package com.kopri.translator

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        var pendingText: String? = null
        var pendingScreen: Int? = null
        var clipboardRunning = false

        private val trailingUrl =
            Regex(
                "[\\s\\r\\n]*(?:[-–—•|]\\s*)?\\(?https?://\\S+\\)?[\\s\\r\\n]*$",
            )
    }

    private var intentChannel: MethodChannel? = null
    private val prefs by lazy { getSharedPreferences("kopri_prefs", MODE_PRIVATE) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CrashHandler.nativeInit()
    }

    // ── AUTO-RETRY INSTALLATION ON RETURN FROM SETTINGS ─────────────────────
    // If user opened "Unknown sources" settings, toggled the switch and came
    // back, this fires automatically. No manual "tap download again" required.
    override fun onResume() {
        super.onResume()
        val pendingPath = prefs.getString("pending_apk_path", null)
        if (pendingPath != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (packageManager.canRequestPackageInstalls()) {
                    prefs.edit().remove("pending_apk_path").apply()
                    installApkNatively(pendingPath)
                }
            } else {
                // Pre-Android 8: no per-app permission, just install
                prefs.edit().remove("pending_apk_path").apply()
                installApkNatively(pendingPath)
            }
        }
    }

    // ── NATIVE APK INSTALLER ────────────────────────────────────────────────
    // Bypasses `android_intent_plus` limitations on OEM ROMs. Explicitly grants
    // read permission to EVERY known system installer package, so Xiaomi/
    // Samsung/Huawei/Oppo/Vivo all pick up the file correctly.
    private fun installApkNatively(path: String) {
        try {
            val file = File(path)
            if (!file.exists()) {
                Log.w("KopriMain", "APK file missing: $path")
                return
            }

            val authority = "$packageName.fileprovider"
            val uri = FileProvider.getUriForFile(this, authority, file)

            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/vnd.android.package-archive")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // Hardcoded list of all known system installer packages across OEMs.
            // `queryIntentActivities` returns empty on Android 11+ without <queries>
            // entries, so we grant permission to everyone who might handle the intent.
            val installerPackages = listOf(
                // AOSP / Google
                "com.android.packageinstaller",
                "com.google.android.packageinstaller",
                // Samsung
                "com.samsung.android.packageinstaller",
                "com.sec.android.app.installapp",
                // Xiaomi / MIUI / HyperOS
                "com.miui.packageinstaller",
                "com.miui.securitymanager",
                // Huawei / EMUI / HarmonyOS
                "com.huawei.systemmanager",
                "com.huawei.appmarket",
                // Oppo / Realme / ColorOS
                "com.oppo.market",
                "com.coloros.safecenter",
                // Vivo / OriginOS
                "com.vivo.appstore",
                "com.bbk.appstore",
                // OnePlus / OxygenOS
                "com.oneplus.appinstaller",
                // Lenovo / Motorola
                "com.lenovo.security",
                "com.motorola.packageinstaller",
                // Asus / HTC / LG / Sony
                "com.asus.appinstaller",
                "com.htc.appinstaller",
                "com.lge.appbox.installer",
                "com.sonyericsson.updatecenter",
                // MediaTek generic
                "com.mediatek.appinstaller",
                // Third-party installers that may take over
                "com.google.android.gms",
                "com.android.vending"
            )

            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION

            for (pkg in installerPackages) {
                try {
                    grantUriPermission(pkg, uri, flags)
                } catch (_: Exception) {
                    // Package not present on this device — silently skip
                }
            }

            startActivity(intent)
            Log.d("KopriMain", "Install intent launched for: $path")
        } catch (e: Exception) {
            Log.e("KopriMain", "installApkNatively failed: ${e.message}", e)
        }
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        ClipboardFilterBridge.attach(engine)

        // ── kopri/apk channel (clipboard, overlay, APK paths) ────────────────
        MethodChannel(engine.dartExecutor.binaryMessenger, "kopri/apk")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getApkPath" -> result.success(applicationInfo.sourceDir)
                    "getCacheDir" -> result.success(cacheDir.absolutePath)
                    "canDrawOverlays" -> result.success(
                        Build.VERSION.SDK_INT < 23 || Settings.canDrawOverlays(this),
                    )
                    "openOverlaySettings" -> {
                        try {
                            startActivity(
                                Intent(
                                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                    Uri.parse("package:$packageName"),
                                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    "startClipboard" -> {
                        if (Build.VERSION.SDK_INT >= 23 && !Settings.canDrawOverlays(this)) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val target = call.argument<String>("target") ?: "ru"
                        val source = call.argument<String>("source") ?: "auto"

                        getSharedPreferences("kopri_prefs", MODE_PRIVATE)
                            .edit()
                            .putString("clip_from", source)
                            .putString("clip_to", target)
                            .apply()

                        if (clipboardRunning) {
                            Log.d("KopriMain", "ClipboardService already running, skipping restart")
                            result.success(true)
                            return@setMethodCallHandler
                        }

                        val si =
                            Intent(this, ClipboardService::class.java)
                                .putExtra("target", target)
                                .putExtra("source", source)
                        if (Build.VERSION.SDK_INT >= 26) {
                            startForegroundService(si)
                        } else {
                            startService(si)
                        }
                        clipboardRunning = true
                        result.success(true)
                    }
                    "stopClipboard" -> {
                        stopService(Intent(this, ClipboardService::class.java))
                        clipboardRunning = false
                        result.success(true)
                    }
                    "isClipboardRunning" -> result.success(clipboardRunning)
                    "setIgnoreNextClipboard" -> {
                        ClipboardService.ignoreNextClipboard = true
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // ── kopri/intent channel (text/share intents) ────────────────────────
        intentChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "kopri/intent")
        intentChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingText" -> {
                    result.success(pendingText)
                    pendingText = null
                }
                "getPendingScreen" -> {
                    result.success(pendingScreen)
                    pendingScreen = null
                }
                else -> result.notImplemented()
            }
        }

        // ── kopri/updates channel (native APK installer) ─────────────────────
        MethodChannel(engine.dartExecutor.binaryMessenger, "kopri/updates")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canInstallPackages" -> {
                        val can = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            packageManager.canRequestPackageInstalls()
                        } else {
                            true // Pre-Android 8: global unknown sources toggle
                        }
                        result.success(can)
                    }

                    "openUnknownSourcesSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            try {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                    Uri.parse("package:$packageName"),
                                )
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                Log.e("KopriMain", "Open unknown sources settings failed", e)
                                result.success(false)
                            }
                        } else {
                            // Pre-Android 8: open global security settings
                            try {
                                val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        }
                    }

                    "installApk" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.success("error")
                            return@setMethodCallHandler
                        }

                        val file = File(path)
                        if (!file.exists()) {
                            result.success("error")
                            return@setMethodCallHandler
                        }

                        // ── Permission gate ──────────────────────────────────
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                            !packageManager.canRequestPackageInstalls()
                        ) {
                            // Save path so onResume can auto-launch install
                            // after user enables the toggle and returns.
                            prefs.edit().putString("pending_apk_path", path).apply()
                            try {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                                    Uri.parse("package:$packageName"),
                                )
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success("needs_permission")
                            } catch (e: Exception) {
                                // Settings open failed: clear pending path
                                prefs.edit().remove("pending_apk_path").apply()
                                Log.e("KopriMain", "Open install settings failed", e)
                                result.success("error")
                            }
                        } else {
                            // ── Permission OK: launch installer natively ─────
                            try {
                                installApkNatively(path)
                                result.success("launched")
                            } catch (e: Exception) {
                                Log.e("KopriMain", "Native install failed", e)
                                result.success("fallback")
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent ?: return

        val screen: Int? =
            when (intent.action) {
                "kopri.OPEN_TRANSLATE" -> 0
                "kopri.OPEN_CAMERA" -> 1
                "kopri.OPEN_PHRASEBOOK" -> 2
                "kopri.OPEN_FLASHCARDS" -> 3
                else -> null
            }
        if (screen != null) {
            pendingScreen = screen
            intentChannel?.invokeMethod("openScreen", screen)
            intent.action = null
            return
        }

        val raw: String? =
            when (intent.action) {
                Intent.ACTION_SEND -> {
                    if (intent.type == "text/plain") {
                        intent.getStringExtra(Intent.EXTRA_TEXT)
                    } else {
                        null
                    }
                }
                Intent.ACTION_PROCESS_TEXT -> {
                    intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
                }
                else -> null
            }

        val text = cleanText(raw)
        if (text.isNotEmpty()) {
            pendingText = text
            intentChannel?.invokeMethod(
                "onText",
                mapOf("text" to text, "id" to System.currentTimeMillis()),
            )
        }

        intent.action = null
        intent.type = null
        intent.removeExtra(Intent.EXTRA_TEXT)
        intent.removeExtra(Intent.EXTRA_PROCESS_TEXT)
    }

    private fun cleanText(raw: String?): String {
        val t = raw?.trim() ?: return ""
        val cleaned = t.replace(trailingUrl, "").trim()
        return cleaned.ifEmpty { t }
    }
}