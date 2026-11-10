package com.hovr.hovr_local_and_push_notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Shows a scheduled notification when its alarm fires, and restores alarms after a reboot. */
class ScheduledNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_FIRE -> {
                val id = intent.getStringExtra(EXTRA_ID) ?: return
                val entry = ScheduledNotificationStore.get(context, id) ?: return
                show(context, entry)
            }
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED ->
                ScheduledNotificationScheduler.restoreAll(context, System.currentTimeMillis())
        }
    }

    companion object {
        const val ACTION_FIRE = "com.hovr.hovr_local_and_push_notification.SCHEDULED_FIRE"
        const val EXTRA_ID = "id"

        internal fun show(context: Context, entry: ScheduledNotification) {
            ScheduledNotificationStore.remove(context, entry.id)
            val shown = LocalNotificationPresenter.show(
                context = context,
                stableId = entry.id,
                title = entry.title,
                body = entry.body,
                channelId = NotificationChannelIds.LOCAL_DEFAULT,
                category = android.app.Notification.CATEGORY_REMINDER,
                playSound = entry.playSound,
            )
            if (!shown) {
                android.util.Log.w("HovrScheduledNotif", "Not shown (notifications blocked): ${entry.id}")
            }
        }
    }
}
