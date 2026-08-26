package com.example.sub_guard

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SpendingOverviewWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_spending_overview).apply {
                val spending = widgetData.getString("overview_spending", "$0.00 / mo")
                val healthBadge = widgetData.getString("overview_health", "On Track")

                val sub1Name = widgetData.getString("overview_sub1_name", "No upcoming renewals")
                val sub1Due = widgetData.getString("overview_sub1_due", "")
                val sub1Amount = widgetData.getString("overview_sub1_amount", "")

                val sub2Name = widgetData.getString("overview_sub2_name", "")
                val sub2Due = widgetData.getString("overview_sub2_due", "")
                val sub2Amount = widgetData.getString("overview_sub2_amount", "")

                setTextViewText(R.id.widget_overview_spending, spending)
                setTextViewText(R.id.widget_overview_health_badge, healthBadge)

                setTextViewText(R.id.widget_sub1_name, sub1Name)
                setTextViewText(R.id.widget_sub1_due, sub1Due)
                setTextViewText(R.id.widget_sub1_amount, sub1Amount)

                if (!sub2Name.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_sub2_container, View.VISIBLE)
                    setTextViewText(R.id.widget_sub2_name, sub2Name)
                    setTextViewText(R.id.widget_sub2_due, sub2Due)
                    setTextViewText(R.id.widget_sub2_amount, sub2Amount)
                } else {
                    setViewVisibility(R.id.widget_sub2_container, View.GONE)
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

