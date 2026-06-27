package com.hovr.hovr_local_and_push_notification

import android.app.Application
import android.app.NotificationManager
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowNotificationManager

@RunWith(RobolectricTestRunner::class)
class NotificationPermissionGateTest {
    @Test
    @Config(sdk = [33])
    fun canDisplay_returnsFalseWhenNotificationsDisabled() {
        val context = ApplicationProvider.getApplicationContext<Application>()
        notificationShadow(context).setNotificationsEnabled(false)

        assertFalse(NotificationPermissionGate.canDisplay(context))
    }

    @Test
    @Config(sdk = [33])
    fun canDisplay_returnsFalseWhenPostNotificationsNotGranted() {
        val context = ApplicationProvider.getApplicationContext<Application>()
        notificationShadow(context).setNotificationsEnabled(true)

        assertFalse(NotificationPermissionGate.canDisplay(context))
    }

    @Test
    @Config(sdk = [24])
    fun canDisplay_returnsTrueOnPreApi33WhenNotificationsEnabled() {
        val context = ApplicationProvider.getApplicationContext<Application>()
        notificationShadow(context).setNotificationsEnabled(true)

        assertTrue(NotificationPermissionGate.canDisplay(context))
    }

    private fun notificationShadow(context: Context): ShadowNotificationManager {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return Shadows.shadowOf(manager)
    }
}
