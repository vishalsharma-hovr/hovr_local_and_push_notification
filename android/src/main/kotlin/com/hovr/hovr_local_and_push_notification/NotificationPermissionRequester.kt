package com.hovr.hovr_local_and_push_notification

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

internal class NotificationPermissionRequester(
    private val activity: ComponentActivity,
) {
    private var pendingCallback: ((Boolean) -> Unit)? = null

    private val permissionLauncher: ActivityResultLauncher<String> =
        activity.registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            pendingCallback?.invoke(granted)
            pendingCallback = null
        }

    fun request(onComplete: (Boolean) -> Unit) {
        if (!NotificationManagerCompat.from(activity).areNotificationsEnabled()) {
            onComplete(false)
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            onComplete(true)
            return
        }
        val permission = Manifest.permission.POST_NOTIFICATIONS
        when {
            ContextCompat.checkSelfPermission(activity, permission) ==
                PackageManager.PERMISSION_GRANTED -> onComplete(true)
            else -> {
                pendingCallback = onComplete
                permissionLauncher.launch(permission)
            }
        }
    }
}
