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
        manager.createNotificationChannel(
            NotificationChannel(
                NotificationChannelIds.RIDE_STATUS,
                "Ride updates",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Active ride status and driver alerts"
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                NotificationChannelIds.RIDE_PROMO,
                "Offers & tips",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Promotions and recommendations"
            },
        )
        manager.createNotificationChannel(
            NotificationChannel(
                NotificationChannelIds.LOCAL_DEFAULT,
                "App alerts",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "In-app and local alerts"
            },
        )
    }

    fun show(
        context: Context,
        stableId: String,
        title: String,
        body: String,
        channelId: String,
        category: String? = null,
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
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(
                if (channelId == NotificationChannelIds.RIDE_STATUS) {
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
