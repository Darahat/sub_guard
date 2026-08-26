package com.example.sub_guard

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class UpcomingRenewalWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_upcoming_renewal).apply {
                val serviceName = widgetData.getString("upcoming_service_name", "No upcoming renewals")
                val amount = widgetData.getString("upcoming_amount", "$0.00")
                val renewalDate = widgetData.getString("upcoming_date", "All caught up")
                val dueBadge = widgetData.getString("upcoming_badge", "Due Soon")

                setTextViewText(R.id.widget_service_name, serviceName)
                setTextViewText(R.id.widget_amount, amount)
                setTextViewText(R.id.widget_renewal_date, renewalDate)
                setTextViewText(R.id.widget_due_badge, dueBadge)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

