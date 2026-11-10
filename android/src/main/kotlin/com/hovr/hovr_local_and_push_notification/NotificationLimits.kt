package com.hovr.hovr_local_and_push_notification

object NotificationLimits {
    const val MAX_PENDING_EVENTS = 32
    const val MAX_ID_REGISTRY = 64
    const val MAX_ID_LENGTH = 64
    const val MAX_TITLE_LENGTH = 128
    const val MAX_BODY_LENGTH = 512
    const val MIN_DELAY_SECONDS = 1
    const val MAX_DELAY_SECONDS = 3600

    /** Most notifications that can wait at once (matches the iOS budget). */
    const val MAX_SCHEDULED = 64

    /** Furthest ahead a notification can be scheduled: 30 days. */
    const val MAX_SCHEDULE_AHEAD_MS = 30L * 24 * 60 * 60 * 1000

    /** After a reboot, a notification missed by up to 15 minutes is still shown. */
    const val RESTORE_GRACE_MS = 15L * 60 * 1000
}
