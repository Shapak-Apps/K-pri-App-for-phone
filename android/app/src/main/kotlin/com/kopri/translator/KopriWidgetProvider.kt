package com.kopri.translator

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class KopriWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val source =
            widgetData.getString("last_source", null)
                ?: context.getString(R.string.widget_hint)
        val result = widgetData.getString("last_result", null) ?: ""
        val pair = widgetData.getString("last_pair", null) ?: ""

        // A tap opens the app on the Translate tab, like the app shortcut.
        val open =
            Intent(context, MainActivity::class.java)
                .setAction("kopri.OPEN_TRANSLATE")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val tap =
            PendingIntent.getActivity(
                context,
                0,
                open,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        for (id in appWidgetIds) {
            val views =
                RemoteViews(context.packageName, R.layout.kopri_widget_layout).apply {
                    setTextViewText(R.id.widget_source, source)
                    setTextViewText(R.id.widget_result, result)
                    setTextViewText(R.id.widget_pair, pair)
                    setOnClickPendingIntent(R.id.widget_root, tap)
                }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
