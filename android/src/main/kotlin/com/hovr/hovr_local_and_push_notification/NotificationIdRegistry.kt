package com.hovr.hovr_local_and_push_notification

internal object NotificationIdRegistry {
    private val ids = LinkedHashMap<String, Int>()

    fun notificationIdFor(stableId: String): Int {
        val existing = ids[stableId]
        if (existing != null) {
            return existing
        }
        if (ids.size >= NotificationLimits.MAX_ID_REGISTRY) {
            val oldest = ids.entries.firstOrNull()
            if (oldest != null) {
                ids.remove(oldest.key)
            }
        }
        val next = stableId.hashCode()
        ids[stableId] = next
        return next
    }

    fun remove(stableId: String) {
        ids.remove(stableId)
    }

    fun clear() {
        ids.clear()
    }
}
