# hovr_local_and_push_notification

Local and push (FCM) notifications for HOVR rider apps — show on-device banners, receive FCM push, and stream tap/token events to Dart.

**Features:** `showLocal`, `cancelLocal`, `cancelAllLocal`, `getFcmToken`, `pushEvents`

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

- **Permissions:** use [`hovr_device_permissions`](https://github.com/vishalsharma-hovr/hovr_device_permissions) for notification prompts; this plugin displays only.
- **iOS push:** test on a physical device; host must call `HovrLocalAndPushNotificationPlugin.setApnsToken` from `AppDelegate`.
- **Android:** FCM service and notification channels are registered by the plugin manifest.
