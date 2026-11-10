package com.hovr.hovr_local_and_push_notification

import android.content.Context

/**
 * Saves scheduled notifications so they can be shown by the alarm receiver
 * and set again after a restart (Android clears alarms on reboot).
 */
internal object ScheduledNotificationStore {
    private const val PREFS = "hovr_scheduled_local_notifications"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun save(context: Context, entry: ScheduledNotification) {
        prefs(context).edit().putString(entry.id, entry.toJson()).apply()
    }

    fun get(context: Context, id: String): ScheduledNotification? =
        prefs(context).getString(id, null)?.let(ScheduledNotification::fromJson)

    fun all(context: Context): List<ScheduledNotification> =
        prefs(context).all.values.mapNotNull { (it as? String)?.let(ScheduledNotification::fromJson) }

    fun contains(context: Context, id: String): Boolean = prefs(context).contains(id)

    fun count(context: Context): Int = prefs(context).all.size

    fun remove(context: Context, id: String) {
        prefs(context).edit().remove(id).apply()
    }

    fun clear(context: Context) {
        prefs(context).edit().clear().apply()
    }
}
