package com.hovr.hovr_local_and_push_notification

import android.content.Context
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class HovrLocalAndPushNotificationPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var appContext: Context
    private lateinit var methodChannel: MethodChannel
    private val pushBuffer = PushEventBuffer()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        instance = this
        LocalNotificationPresenter.ensureChannels(appContext)

        methodChannel = MethodChannel(binding.binaryMessenger, ChannelNames.METHOD)
        methodChannel.setMethodCallHandler(this)

        EventChannel(binding.binaryMessenger, ChannelNames.PUSH_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (events != null) {
                        pushBuffer.attach(events)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    pushBuffer.detach()
                }
            },
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        pushBuffer.detach()
        if (instance === this) {
            instance = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_GET_FCM_TOKEN -> getFcmToken(result)
            METHOD_SHOW_LOCAL -> showLocal(call, result)
            METHOD_CANCEL_LOCAL -> cancelLocal(call, result)
            METHOD_CANCEL_ALL_LOCAL -> {
                LocalNotificationPresenter.cancelAll(appContext)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun getFcmToken(result: MethodChannel.Result) {
        if (FirebaseApp.getApps(appContext).isEmpty()) {
            result.error("FIREBASE_NOT_INITIALIZED", "Firebase is not initialized in the host app.", null)
            return
        }
        FirebaseMessaging.getInstance().token
            .addOnSuccessListener { token -> result.success(token) }
            .addOnFailureListener { error ->
                result.error("FCM_ERROR", "Failed to get FCM token", error.message)
            }
    }

    private fun showLocal(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        val title = call.argument<String>("title")
        val body = call.argument<String>("body")
        if (id.isNullOrBlank() || title.isNullOrBlank() || body.isNullOrBlank()) {
            result.error("MISSING_ARG", "id, title, and body are required", null)
            return
        }
        if (id.length > NotificationLimits.MAX_ID_LENGTH ||
            title.length > NotificationLimits.MAX_TITLE_LENGTH ||
            body.length > NotificationLimits.MAX_BODY_LENGTH
        ) {
            result.error("INVALID_ARG", "Argument length exceeded", null)
            return
        }
        val delaySeconds = (call.argument<Int>("delaySeconds") ?: NotificationLimits.MIN_DELAY_SECONDS)
            .coerceIn(NotificationLimits.MIN_DELAY_SECONDS, NotificationLimits.MAX_DELAY_SECONDS)
        val playSound = call.argument<Boolean>("playSound") ?: true
        if (delaySeconds > NotificationLimits.MIN_DELAY_SECONDS) {
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                val shown = postLocal(id, title, body, playSound)
                result.success(shown)
            }, delaySeconds * 1000L)
            return
        }
        result.success(postLocal(id, title, body, playSound))
    }

    private fun postLocal(id: String, title: String, body: String, playSound: Boolean): Boolean {
        return LocalNotificationPresenter.show(
            context = appContext,
            stableId = id,
            title = title,
            body = body,
            channelId = NotificationChannelIds.LOCAL_DEFAULT,
            category = android.app.Notification.CATEGORY_STATUS,
        )
    }

    private fun cancelLocal(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        if (id.isNullOrBlank()) {
            result.error("MISSING_ARG", "id is required", null)
            return
        }
        LocalNotificationPresenter.cancel(appContext, id)
        result.success(null)
    }

    companion object {
        const val METHOD_GET_FCM_TOKEN = ChannelNames.GET_FCM_TOKEN
        const val METHOD_SHOW_LOCAL = ChannelNames.SHOW_LOCAL
        const val METHOD_CANCEL_LOCAL = ChannelNames.CANCEL_LOCAL
        const val METHOD_CANCEL_ALL_LOCAL = ChannelNames.CANCEL_ALL_LOCAL

        @Volatile
        var instance: HovrLocalAndPushNotificationPlugin? = null

        fun emitPushEvent(event: Map<String, Any?>) {
            instance?.pushBuffer?.emit(event)
        }
    }
}
