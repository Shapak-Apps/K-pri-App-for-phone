package com.kopri.translator

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "kopri/apk"
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getApkPath" -> result.success(applicationInfo.sourceDir)
                    "getCacheDir" -> result.success(cacheDir.absolutePath)
                    else -> result.notImplemented()
                }
            }
    }
}