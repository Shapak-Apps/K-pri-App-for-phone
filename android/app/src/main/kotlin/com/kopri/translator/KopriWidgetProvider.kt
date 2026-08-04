package com.kopri.translator

import android.appwidget.AppWidgetManager
import android.content.Context
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
                ?: "Переведи что-нибудь..."
        val result = widgetData.getString("last_result", null) ?: ""
        val pair = widgetData.getString("last_pair", null) ?: ""

        widgetData.getString("last_source", null)

        for (id in appWidgetIds) {
            val views =
                RemoteViews(context.packageName, R.layout.kopri_widget_layout).apply {
                    setTextViewText(R.id.widget_source, source)
                    setTextViewText(R.id.widget_result, result)
                    setTextViewText(R.id.widget_pair, pair)
                }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
