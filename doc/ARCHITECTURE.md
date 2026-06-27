# Architecture

```
Dart (HovrLocalAndPushNotification)
  → MethodChannel + EventChannel
  → HovrLocalAndPushNotificationPlugin
  → LocalNotificationPresenter / HovrFirebaseMessagingService
  → OS notification surface
```

| Layer | Owner |
|-------|-------|
| Permission prompts | `hovr_device_permissions` |
| Display local + push | `hovr_local_and_push_notification` |
| Token register with backend | Host (`splash_screen.dart`) |
| Cold-start tap routing | Host + `firebase_messaging.getInitialMessage()` |

See [PERMISSION_GUIDELINES.md](PERMISSION_GUIDELINES.md) and [CHANNEL_CONTRACT.md](CHANNEL_CONTRACT.md).
