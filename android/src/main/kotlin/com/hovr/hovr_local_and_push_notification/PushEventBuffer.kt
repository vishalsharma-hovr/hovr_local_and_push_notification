package com.hovr.hovr_local_and_push_notification

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

internal class PushEventBuffer {
    private val pending = ArrayDeque<Map<String, Any?>>()
    private var sink: EventChannel.EventSink? = null

    fun attach(sink: EventChannel.EventSink) {
        this.sink = sink
        flushPending()
    }

    fun detach() {
        sink = null
    }

    fun emit(event: Map<String, Any?>) {
        val active = sink
        if (active != null) {
            Handler(Looper.getMainLooper()).post { active.success(event) }
            return
        }
        synchronized(pending) {
            if (pending.size >= NotificationLimits.MAX_PENDING_EVENTS) {
                pending.removeFirst()
            }
            pending.addLast(event)
        }
    }

    private fun flushPending() {
        val active = sink ?: return
        val toSend = synchronized(pending) {
            pending.toList().also { pending.clear() }
        }
        Handler(Looper.getMainLooper()).post {
            for (event in toSend) {
                active.success(event)
            }
        }
    }
}
