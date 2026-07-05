# Integration

## Dependency

**Monorepo (local):**

```yaml
hovr_local_and_push_notification:
  path: packages/hovr_local_and_push_notification
```

**Published (git):**

```yaml
hovr_local_and_push_notification:
  git:
    url: https://github.com/vishalsharma-hovr/hovr_local_and_push_notification.git
    ref: v0.1.0
```

Remove legacy git `hovr_notification` after migration ([HOST_MIGRATION.md](HOST_MIGRATION.md)).

## Host requirements

- `firebase_core`, `firebase_messaging` initialized before `getFcmToken()`
- `google-services.json` / `GoogleService-Info.plist`
- `POST_NOTIFICATIONS` (Android) — `hovr_device_permissions` requests permission
- iOS: Push capability, `NSUserNotificationsUsageDescription`, `UIBackgroundModes` includes `remote-notification`

## AppDelegate (iOS)

```swift
import hovr_local_and_push_notification

override func application(
  _ application: UIApplication,
  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
  HovrLocalAndPushNotificationPlugin.setApnsToken(deviceToken)
  super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
}
```

## Dart

```dart
final notifications = HovrLocalAndPushNotification();
notifications.pushEvents.listen(_onPush);
final token = await notifications.getFcmToken();
```

Also handle `FirebaseMessaging.onMessageOpenedApp` and `getInitialMessage()` in host for terminated cold start.

Re-register FCM token with your backend on login/logout and when `pushEvents` emits `type: token`.

## Native (LocationUpdatesService)

```swift
import hovr_local_and_push_notification

LocalNotificationPresenter.show(
  id: "locationTracking",
  title: "Tracking Location",
  body: "Your location is being sent every few seconds."
)
```

## Troubleshooting

- **Background trip updates:** local notifications from the gRPC trip stream only fire while Dart is running. For updates while the app is backgrounded, the server must send FCM (see `doc/FCM_PAYLOAD.md`). The host should sync on resume (`SyncTripStatusNotificationEvent` in rider `TripBloc`).
- Android channel importance is cached after first install — **clear app data or reinstall** after upgrading channel settings (e.g. lock-screen visibility)
- iOS push: test on **physical device**; verify APNs `.p8` in Firebase and bundle ID match
- `getFcmToken()` nil on iOS: ensure `setApnsToken` is called
- OEM battery savers may block FCM on some Android devices
