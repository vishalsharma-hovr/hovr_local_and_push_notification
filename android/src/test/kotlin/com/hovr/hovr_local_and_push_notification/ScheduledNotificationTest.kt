package com.hovr.hovr_local_and_push_notification

import android.app.AlarmManager
import android.app.Application
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class ScheduledNotificationTest {
    private val now = 1_800_000_000_000L
    private val hour = 60 * 60 * 1000L
    private lateinit var context: Context

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext<Application>()
        ScheduledNotificationStore.clear(context)
    }

    private fun entry(id: String = "trip_1_2h", fireAt: Long = now + hour) =
        ScheduledNotification(id, "Ride soon", "Pickup at 4:30 pm", fireAt, playSound = true)

    @Test
    fun json_roundTripKeepsEveryField() {
        val original = entry()
        assertEquals(original, ScheduledNotification.fromJson(original.toJson()))
    }

    @Test
    fun fromJson_returnsNullForBrokenData() {
        assertNull(ScheduledNotification.fromJson("not json"))
        assertNull(ScheduledNotification.fromJson("{\"id\":\"x\"}"))
    }

    @Test
    fun canSchedule_onlyFutureTimesWithinThirtyDays() {
        assertTrue(entry(fireAt = now + hour).canSchedule(now))
        assertFalse(entry(fireAt = now).canSchedule(now))
        assertFalse(entry(fireAt = now - 1).canSchedule(now))
        assertFalse(entry(fireAt = now + 31 * 24 * hour).canSchedule(now))
    }

    @Test
    fun restoreAction_firesShortlyMissedAndDropsStaleOnes() {
        assertEquals(RestoreAction.SCHEDULE, entry(fireAt = now + hour).restoreAction(now))
        assertEquals(RestoreAction.SHOW_NOW, entry(fireAt = now - 5 * 60 * 1000L).restoreAction(now))
        assertEquals(RestoreAction.DROP, entry(fireAt = now - hour).restoreAction(now))
    }

    @Test
    fun store_saveReplaceAndRemove() {
        ScheduledNotificationStore.save(context, entry())
        ScheduledNotificationStore.save(context, entry().copy(body = "Updated"))
        ScheduledNotificationStore.save(context, entry(id = "trip_1_1h"))

        assertEquals("Updated", ScheduledNotificationStore.get(context, "trip_1_2h")?.body)
        assertEquals(2, ScheduledNotificationStore.all(context).size)

        ScheduledNotificationStore.remove(context, "trip_1_2h")
        assertNull(ScheduledNotificationStore.get(context, "trip_1_2h"))
        assertEquals(1, ScheduledNotificationStore.all(context).size)
    }

    @Test
    fun scheduler_rejectsWhenFull() {
        repeat(NotificationLimits.MAX_SCHEDULED) { index ->
            assertTrue(ScheduledNotificationScheduler.schedule(context, entry(id = "id_$index"), now))
        }
        assertFalse(ScheduledNotificationScheduler.schedule(context, entry(id = "one_more"), now))
        // Replacing an existing id is still allowed when full.
        assertTrue(ScheduledNotificationScheduler.schedule(context, entry(id = "id_0"), now))
    }

    @Test
    fun scheduler_setsAndCancelsAlarm() {
        val alarms = Shadows.shadowOf(context.getSystemService(AlarmManager::class.java))

        assertTrue(ScheduledNotificationScheduler.schedule(context, entry(), now))
        assertEquals(now + hour, alarms.peekNextScheduledAlarm()?.triggerAtTime)

        ScheduledNotificationScheduler.cancel(context, "trip_1_2h")
        assertNull(alarms.peekNextScheduledAlarm())
        assertNull(ScheduledNotificationStore.get(context, "trip_1_2h"))
    }

    @Test
    fun scheduler_rejectsPastTimeWithoutSavingIt() {
        assertFalse(ScheduledNotificationScheduler.schedule(context, entry(fireAt = now - 1), now))
        assertTrue(ScheduledNotificationStore.all(context).isEmpty())
    }
}
