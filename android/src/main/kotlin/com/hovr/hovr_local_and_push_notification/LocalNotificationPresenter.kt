package com.hovr.hovr_local_and_push_notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

internal object LocalNotificationPresenter {
    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        createChannel(
            manager = manager,
            id = NotificationChannelIds.RIDE_STATUS,
            name = "Ride updates",
            importance = NotificationManager.IMPORTANCE_HIGH,
            description = "Active ride status and driver alerts",
        )
        createChannel(
            manager = manager,
            id = NotificationChannelIds.RIDE_PROMO,
            name = "Offers & tips",
            importance = NotificationManager.IMPORTANCE_LOW,
            description = "Promotions and recommendations",
        )
        createChannel(
            manager = manager,
            id = NotificationChannelIds.LOCAL_DEFAULT,
            name = "App alerts",
            importance = NotificationManager.IMPORTANCE_HIGH,
            description = "In-app and local alerts",
        )
    }

    private fun createChannel(
        manager: NotificationManager,
        id: String,
        name: String,
        importance: Int,
        description: String,
    ) {
        val channel = NotificationChannel(id, name, importance).apply {
            this.description = description
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            if (importance >= NotificationManager.IMPORTANCE_HIGH) {
                enableLights(true)
                enableVibration(true)
            }
        }
        manager.createNotificationChannel(channel)
    }

    fun show(
        context: Context,
        stableId: String,
        title: String,
        body: String,
        channelId: String,
        category: String? = null,
        playSound: Boolean = true,
    ): Boolean {
        if (!NotificationPermissionGate.canDisplay(context)) {
            return false
        }
        ensureChannels(context)
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            stableId.hashCode(),
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val highPriorityChannel = channelId == NotificationChannelIds.RIDE_STATUS ||
            channelId == NotificationChannelIds.LOCAL_DEFAULT
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            // Expandable so multi-line bodies (e.g. pickup and drop-off) are readable.
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setDefaults(
                if (playSound) {
                    NotificationCompat.DEFAULT_ALL
                } else {
                    NotificationCompat.DEFAULT_LIGHTS
                },
            )
            .setPriority(
                if (highPriorityChannel) {
                    NotificationCompat.PRIORITY_HIGH
                } else {
                    NotificationCompat.PRIORITY_DEFAULT
                },
            )
        if (category != null) {
            builder.setCategory(category)
        }
        NotificationManagerCompat.from(context).notify(
            NotificationIdRegistry.notificationIdFor(stableId),
            builder.build(),
        )
        return true
    }

    fun cancel(context: Context, stableId: String) {
        NotificationManagerCompat.from(context).cancel(
            NotificationIdRegistry.notificationIdFor(stableId),
        )
        NotificationIdRegistry.remove(stableId)
    }

    fun cancelAll(context: Context) {
        NotificationManagerCompat.from(context).cancelAll()
        NotificationIdRegistry.clear()
    }
}
