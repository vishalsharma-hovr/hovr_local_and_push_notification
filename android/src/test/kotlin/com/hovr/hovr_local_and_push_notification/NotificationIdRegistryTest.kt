package com.hovr.hovr_local_and_push_notification

import org.junit.Assert.assertEquals
import org.junit.Test

class NotificationIdRegistryTest {
    @Test
    fun notificationIdFor_isStableForSameKey() {
        NotificationIdRegistry.clear()
        val first = NotificationIdRegistry.notificationIdFor("ride-1")
        val second = NotificationIdRegistry.notificationIdFor("ride-1")
        assertEquals(first, second)
    }
}
