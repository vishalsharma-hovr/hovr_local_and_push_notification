# hovr_local_and_push_notification

Local and push (FCM) notifications for HOVR rider apps — show on-device banners, receive FCM push, and stream tap/token events to Dart.

**Features:** `showLocal`, `postLocal`, `requestNotificationPermission`, `cancelLocal`, `cancelAllLocal`, `getFcmToken`, `pushEvents`

## Usage

```yaml
dependencies:
  hovr_local_and_push_notification:
    git:
      url: https://github.com/vishalsharma-hovr/hovr_local_and_push_notification.git
      ref: v0.1.0
```

Local development (monorepo):

```yaml
dependency_overrides:
  hovr_local_and_push_notification:
    path: packages/hovr_local_and_push_notification
```

```dart
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';

final notifications = HovrLocalAndPushNotification();
notifications.pushEvents.listen(_onPush);
final token = await notifications.getFcmToken();
await notifications.postLocal(
  id: 'trip_status_123',
  title: 'Trip update',
  body: 'Your driver is on the way.',
  logTag: 'TripStatus',
);
```

Or call `showLocal` directly when permission is already granted:

```dart
await notifications.showLocal(
  id: 'locationTracking',
  title: 'Tracking Location',
  body: 'Your location is being sent every few seconds.',
);
```

## Documentation

- [Integration](doc/INTEGRATION.md)
- [Host migration](doc/HOST_MIGRATION.md)
- [Architecture](doc/ARCHITECTURE.md)
- [Channel contract](doc/CHANNEL_CONTRACT.md)
- [Industry benchmarks](doc/INDUSTRY_BENCHMARKS.md)
- [Contributing](CONTRIBUTING.md)

## Platform notes

- **Permissions:** `hovr_device_permissions` handles first-launch prompts; `postLocal` / `requestNotificationPermission` recover when display is denied.
- **iOS push:** test on a physical device; host must call `HovrLocalAndPushNotificationPlugin.setApnsToken` from `AppDelegate`.
- **Android:** FCM service and notification channels are registered by the plugin manifest.
