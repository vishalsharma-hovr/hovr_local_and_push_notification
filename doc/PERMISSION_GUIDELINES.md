# Permission guidelines

| Concern | Owner |
|---------|-------|
| Request notification permission | `hovr_device_permissions` |
| Check before display | `hovr_local_and_push_notification` |
| Register for remote (iOS) | `hovr_device_permissions` after grant |

This plugin **must not** call `requestAuthorization` or `ActivityCompat.requestPermissions` for notifications.
