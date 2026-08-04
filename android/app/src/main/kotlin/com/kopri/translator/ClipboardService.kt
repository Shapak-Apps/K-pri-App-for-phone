package com.kopri.translator

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.OvershootInterpolator
import android.widget.ImageView
import android.widget.TextView
import java.util.Locale

class ClipboardService :
    Service(),
    TextToSpeech.OnInitListener {
    companion object {
        private const val TAG = "KopriClip"
        private const val NOTIF_ID = 911
        private const val CHANNEL = "kopri_clipboard"
    }

    private lateinit var clipboard: ClipboardManager
    private lateinit var wm: WindowManager
    private val handler = Handler(Looper.getMainLooper())
    private var tts: TextToSpeech? = null
    private var ttsReady = false

    private var bubble: View? = null
    private var lastText: String? = null
    private var skipNext = false

    private var source = "auto"
    private var target = "ru"
    private var debounce: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        tts = TextToSpeech(this, this)
        clipboard.addPrimaryClipChangedListener { onCopy() }

        val prefs = getSharedPreferences("kopri_prefs", MODE_PRIVATE)
        source = prefs.getString("clip_from", "auto") ?: "auto"
        target = prefs.getString("clip_to", "ru") ?: "ru"

        Log.w(TAG, "service created, pair: $source → $target")
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        intent?.getStringExtra("source")?.let { source = it }
        intent?.getStringExtra("target")?.let { target = it }
        startForeground(NOTIF_ID, notification())
        handler.post { showCollapsed() }
        return START_NOT_STICKY
    }

    override fun onInit(status: Int) {
        ttsReady = status == TextToSpeech.SUCCESS
    }

    override fun onDestroy() {
        MainActivity.clipboardRunning = false
        hideBubble()
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }

    // ── буфер изменился ──────────────────────────────────────────
    private fun onCopy() {
        if (skipNext) {
            skipNext = false
            return
        }
        val text = readClipboard() ?: return
        if (text.isEmpty() || text == lastText || text.length > 600) return
        lastText = text
        Log.w(TAG, "clipboard changed: ${text.take(30)}...")

        debounce?.let { handler.removeCallbacks(it) }
        debounce = Runnable { translateAndShow(text) }
        handler.postDelayed(debounce!!, 600)
    }

    private fun readClipboard(): String? =
        try {
            clipboard.primaryClip
                ?.getItemAt(0)
                ?.coerceToText(this)
                ?.toString()
                ?.trim()
        } catch (e: Exception) {
            null
        }

    private fun onBubbleTap() {
        val text = readClipboard()
        Log.w(TAG, "bubble tap, clipboard: ${text?.take(30)}")

        if (!text.isNullOrEmpty() && text != lastText) {
            lastText = text
            translateAndShow(text)
        } else if (!text.isNullOrEmpty()) {
            showLastTranslation(text)
        } else {
            if (lastText != null) {
                showLastTranslation(lastText!!)
            }
        }
    }

    private fun showLastTranslation(text: String) {
        // если есть сохранённый перевод — показываем
        val prefs = getSharedPreferences("kopri_clip_cache", MODE_PRIVATE)
        val cachedOriginal = prefs.getString("last_original", null)
        val cachedTranslated = prefs.getString("last_translated", null)

        if (cachedOriginal == text && !cachedTranslated.isNullOrEmpty()) {
            showExpanded(text, cachedTranslated)
        } else {
            translateAndShow(text)
        }
    }

    private fun translateAndShow(text: String) {
        Thread {
            val (actualTarget, translated) = Net.translateWithPair(text, source, target)
            if (!translated.isNullOrEmpty()) {
                getSharedPreferences("kopri_clip_cache", MODE_PRIVATE)
                    .edit()
                    .putString("last_original", text)
                    .putString("last_translated", translated)
                    .putString("last_target", actualTarget)
                    .apply()

                handler.post { showExpanded(text, translated) }
            }
        }.start()
    }

    // ── свёрнутый пузырёк ────────────────────────────────────────
    @SuppressLint("ClickableViewAccessibility", "InflateParams")
    private fun showCollapsed() {
        hideBubble()
        val view = LayoutInflater.from(this).inflate(R.layout.bubble_collapsed, null)
        val params = wmParams(dp(56), dp(56))
        attachDrag(view, params) { onBubbleTap() }

        view.scaleX = 0f
        view.scaleY = 0f
        view.alpha = 0f
        wm.addView(view, params)
        bubble = view
        view
            .animate()
            .scaleX(1f)
            .scaleY(1f)
            .alpha(1f)
            .setDuration(280)
            .setInterpolator(OvershootInterpolator(2.2f))
            .start()
    }

    // ── раскрытая карточка ───────────────────────────────────────
    @SuppressLint("InflateParams")
    private fun showExpanded(
        original: String,
        translated: String,
    ) {
        hideBubble()

        val view = LayoutInflater.from(this).inflate(R.layout.bubble_expanded, null)
        view.findViewById<TextView>(R.id.bubble_original).text = original
        view.findViewById<TextView>(R.id.bubble_translated).text = translated

        view.findViewById<ImageView>(R.id.bubble_copy).setOnClickListener {
            skipNext = true
            clipboard.setPrimaryClip(ClipData.newPlainText("Köpri", translated))
            showCollapsed()
        }
        view.findViewById<ImageView>(R.id.bubble_speak).setOnClickListener {
            val prefs = getSharedPreferences("kopri_clip_cache", MODE_PRIVATE)
            val actualTarget = prefs.getString("last_target", target) ?: target
            speak(translated, actualTarget)
        }
        view.findViewById<ImageView>(R.id.bubble_open).setOnClickListener {
            openInApp(original)
        }
        view.findViewById<ImageView>(R.id.bubble_close).setOnClickListener {
            showCollapsed()
        }

        val params = wmParams(dp(310), WindowManager.LayoutParams.WRAP_CONTENT)
        wm.addView(view, params)
        bubble = view

        view.scaleX = 0.7f
        view.scaleY = 0.7f
        view.alpha = 0f
        view
            .animate()
            .scaleX(1f)
            .scaleY(1f)
            .alpha(1f)
            .setDuration(240)
            .setInterpolator(OvershootInterpolator(1.4f))
            .start()
    }

    private fun hideBubble() {
        bubble?.let {
            try {
                wm.removeView(it)
            } catch (_: Exception) {
            }
        }
        bubble = null
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun attachDrag(
        view: View,
        params: WindowManager.LayoutParams,
        onTap: () -> Unit,
    ) {
        var startX = 0f
        var startY = 0f
        var baseX = 0
        var baseY = 0
        var moved = false
        view.setOnTouchListener { _, ev ->
            when (ev.action) {
                MotionEvent.ACTION_DOWN -> {
                    startX = ev.rawX
                    startY = ev.rawY
                    baseX = params.x
                    baseY = params.y
                    moved = false
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = ev.rawX - startX
                    val dy = ev.rawY - startY
                    if (Math.abs(dx) > 10 || Math.abs(dy) > 10) moved = true
                    if (moved) {
                        params.x = baseX + dx.toInt()
                        params.y = baseY + dy.toInt()
                        try {
                            wm.updateViewLayout(view, params)
                        } catch (_: Exception) {
                        }
                    }
                    true
                }

                MotionEvent.ACTION_UP -> {
                    if (!moved) onTap()
                    true
                }

                else -> {
                    false
                }
            }
        }
    }

    private fun wmParams(
        w: Int,
        h: Int,
    ): WindowManager.LayoutParams {
        val d = resources.displayMetrics
        return WindowManager
            .LayoutParams(
                w,
                h,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT,
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                x = dp(16)
                y = d.heightPixels / 3
            }
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density).toInt()

    private fun openInApp(text: String) {
        try {
            val i =
                Intent(this, MainActivity::class.java).apply {
                    action = Intent.ACTION_SEND
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            startActivity(i)
        } catch (_: Exception) {
        }
        showCollapsed()
    }

    private fun speak(
        text: String,
        lang: String,
    ) {
        if (!ttsReady || text.isEmpty()) return
        val loc =
            when (lang) {
                "ru" -> Locale("ru")
                "en" -> Locale("en")
                "tr" -> Locale("tr")
                "tk" -> Locale("tk")
                else -> Locale(lang)
            }
        tts?.language = loc
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "kopri_bubble")
    }

    private fun notification(): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel(
                    CHANNEL,
                    "Köpri Clipboard",
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val open = packageManager.getLaunchIntentForPackage(packageName)
        val pi =
            open?.let {
                PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE)
            }
        return Notification
            .Builder(this, CHANNEL)
            .setContentTitle("Köpri")
            .setContentText(getString(R.string.clipboard_notif))
            .setSmallIcon(R.drawable.ic_notify)
            .setContentIntent(pi)
            .setOngoing(true)
            .build()
    }
}
