package com.hovr.hovr_local_and_push_notification

import org.json.JSONException
import org.json.JSONObject

/** What to do with a saved notification after the phone restarts. */
internal enum class RestoreAction { SCHEDULE, SHOW_NOW, DROP }

/** A local notification waiting for its alarm. [fireAtEpochMs] is wall-clock time. */
internal data class ScheduledNotification(
    val id: String,
    val title: String,
    val body: String,
    val fireAtEpochMs: Long,
    val playSound: Boolean,
) {
    /** Only future times up to [NotificationLimits.MAX_SCHEDULE_AHEAD_MS] ahead. */
    fun canSchedule(nowEpochMs: Long): Boolean =
        fireAtEpochMs > nowEpochMs &&
            fireAtEpochMs - nowEpochMs <= NotificationLimits.MAX_SCHEDULE_AHEAD_MS

    /** Missed while the phone was off: show if only just missed, otherwise drop it. */
    fun restoreAction(nowEpochMs: Long): RestoreAction = when {
        fireAtEpochMs > nowEpochMs -> RestoreAction.SCHEDULE
        nowEpochMs - fireAtEpochMs <= NotificationLimits.RESTORE_GRACE_MS -> RestoreAction.SHOW_NOW
        else -> RestoreAction.DROP
    }

    fun toJson(): String = JSONObject()
        .put(KEY_ID, id)
        .put(KEY_TITLE, title)
        .put(KEY_BODY, body)
        .put(KEY_FIRE_AT, fireAtEpochMs)
        .put(KEY_PLAY_SOUND, playSound)
        .toString()

    companion object {
        private const val KEY_ID = "id"
        private const val KEY_TITLE = "title"
        private const val KEY_BODY = "body"
        private const val KEY_FIRE_AT = "fireAtEpochMs"
        private const val KEY_PLAY_SOUND = "playSound"

        /** Returns null for data that is not a complete saved notification. */
        fun fromJson(raw: String): ScheduledNotification? = try {
            val json = JSONObject(raw)
            ScheduledNotification(
                id = json.getString(KEY_ID),
                title = json.getString(KEY_TITLE),
                body = json.getString(KEY_BODY),
                fireAtEpochMs = json.getLong(KEY_FIRE_AT),
                playSound = json.optBoolean(KEY_PLAY_SOUND, true),
            )
        } catch (error: JSONException) {
            android.util.Log.w("HovrScheduledNotif", "Dropping unreadable entry: ${error.message}")
            null
        }
    }
}
