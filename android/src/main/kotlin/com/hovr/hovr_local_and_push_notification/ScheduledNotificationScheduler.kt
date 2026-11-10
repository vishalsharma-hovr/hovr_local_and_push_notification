package com.hovr.hovr_local_and_push_notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent

/**
 * Sets an inexact, Doze-safe alarm per notification. Inexact on purpose: exact
 * alarms need SCHEDULE_EXACT_ALARM, which Play only allows for alarm and
 * calendar apps, so a sleeping phone may show it a few minutes late.
 */
internal object ScheduledNotificationScheduler {
    fun schedule(context: Context, entry: ScheduledNotification, nowEpochMs: Long): Boolean {
        if (!entry.canSchedule(nowEpochMs)) {
            return false
        }
        val isReplacement = ScheduledNotificationStore.contains(context, entry.id)
        if (!isReplacement && ScheduledNotificationStore.count(context) >= NotificationLimits.MAX_SCHEDULED) {
            return false
        }
        ScheduledNotificationStore.save(context, entry)
        setAlarm(context, entry)
        return true
    }

    fun cancel(context: Context, id: String) {
        alarmManager(context).cancel(pendingIntent(context, id))
        ScheduledNotificationStore.remove(context, id)
    }

    fun cancelAll(context: Context) {
        ScheduledNotificationStore.all(context).forEach { cancel(context, it.id) }
        ScheduledNotificationStore.clear(context)
    }

    /** After a reboot: set future alarms again, show just-missed ones, drop stale ones. */
    fun restoreAll(context: Context, nowEpochMs: Long) {
        for (entry in ScheduledNotificationStore.all(context)) {
            when (entry.restoreAction(nowEpochMs)) {
                RestoreAction.SCHEDULE -> setAlarm(context, entry)
                RestoreAction.SHOW_NOW -> ScheduledNotificationReceiver.show(context, entry)
                RestoreAction.DROP -> ScheduledNotificationStore.remove(context, entry.id)
            }
        }
    }

    private fun setAlarm(context: Context, entry: ScheduledNotification) {
        alarmManager(context).setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            entry.fireAtEpochMs,
            pendingIntent(context, entry.id),
        )
    }

    private fun alarmManager(context: Context): AlarmManager =
        context.getSystemService(AlarmManager::class.java)

    private fun pendingIntent(context: Context, id: String): PendingIntent {
        val intent = Intent(context, ScheduledNotificationReceiver::class.java)
            .setAction(ScheduledNotificationReceiver.ACTION_FIRE)
            // The data URI makes each id a distinct PendingIntent, so cancel hits only this one.
            .setData(android.net.Uri.fromParts("hovr-local", id, null))
            .putExtra(ScheduledNotificationReceiver.EXTRA_ID, id)
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
