package com.hovr.hovr_local_and_push_notification

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class HovrFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        val title = message.notification?.title ?: message.data["title"]
        val body = message.notification?.body ?: message.data["body"]
        val data = message.data

        HovrLocalAndPushNotificationPlugin.emitPushEvent(
            PushEventMapper.message(
                title = title,
                body = body,
                data = data,
                messageId = message.messageId,
            ),
        )

        if (!title.isNullOrEmpty() || !body.isNullOrEmpty()) {
            LocalNotificationPresenter.show(
                context = this,
                stableId = message.messageId ?: "fcm_${System.currentTimeMillis()}",
                title = title ?: "New notification",
                body = body ?: "",
                channelId = NotificationChannelIds.RIDE_STATUS,
                category = android.app.Notification.CATEGORY_TRANSPORT,
            )
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        HovrLocalAndPushNotificationPlugin.emitPushEvent(PushEventMapper.token(token))
    }
}
