package com.kopri.translator

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

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

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        ClipboardFilterBridge.attach(engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, "kopri/apk")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getApkPath" -> {
                        result.success(applicationInfo.sourceDir)
                    }

                    "getCacheDir" -> {
                        result.success(cacheDir.absolutePath)
                    }

                    "canDrawOverlays" -> {
                        result.success(
                            Build.VERSION.SDK_INT < 23 || Settings.canDrawOverlays(this),
                        )
                    }

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

                    "isClipboardRunning" -> {
                        result.success(clipboardRunning)
                    }

                    // ═══ НОВЫЙ МЕТОД: игнорировать следующее копирование ═══
                    "setIgnoreNextClipboard" -> {
                        ClipboardService.ignoreNextClipboard = true
                        result.success(true)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }

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

                else -> {
                    result.notImplemented()
                }
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

                else -> {
                    null
                }
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