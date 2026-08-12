package com.kopri.translator

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicInteger

object ClipboardFilterBridge {
    private const val CHANNEL = "kopri/clip_filter"
    private var channel: MethodChannel? = null
    private val pendingId = AtomicInteger(0)
    private val pending = mutableMapOf<Int, (Boolean) -> Unit>()
    private val handler = Handler(Looper.getMainLooper())

    fun attach(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "filterResult") {
                val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                val should = call.argument<Boolean>("should") ?: true
                val cb = synchronized(pending) { pending.remove(id) }
                cb?.invoke(should)
                result.success(null)
            }
        }
    }

    fun shouldTranslate(text: String, onResult: (Boolean) -> Unit) {
        val ch = channel
        if (ch == null) {
            onResult(true)
            return
        }

        val id = pendingId.incrementAndGet()
        synchronized(pending) { pending[id] = onResult }

        handler.post {
            try {
                ch.invokeMethod("classify", mapOf("id" to id, "text" to text))
            } catch (e: Exception) {
                synchronized(pending) { pending.remove(id) }
                onResult(true)
            }
        }

        handler.postDelayed({
            val cb = synchronized(pending) { pending.remove(id) }
            cb?.invoke(true)
        }, 800)
    }
}