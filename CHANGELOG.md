## 0.2.0

- Add `scheduleLocal(id, title, body, fireAt)`: a local notification at a set time that survives the app being closed. Android uses an inexact `AlarmManager` alarm and restores pending ones after a reboot (`RECEIVE_BOOT_COMPLETED`); iOS uses `UNCalendarNotificationTrigger`. Limits: up to 30 days ahead, 64 pending.
- `cancelLocal` and `cancelAllLocal` also cancel scheduled notifications.
- Android local notifications expand to show multi-line bodies (`BigTextStyle`).
- No breaking changes. Custom `HovrLocalAndPushNotificationPlatform` implementations get a default `scheduleLocal` that throws `UnimplementedError`.

## 0.1.4

- Fix Android Gradle config so `HovrFirebaseMessagingService` is always packaged in release builds.
- Remove standalone `settings.gradle` files from the plugin `android/` folder.
- Add consumer ProGuard keep rules for the FCM service class.

## 0.1.2

- Add `requestNotificationPermission()` and `postLocal()` with permission retry helper.
- Lock-screen visibility improvements from 0.1.1 retained.

## 0.1.1

- Raise `hovr_local_default` to HIGH importance with public lock-screen visibility on Android.
- Local notifications use `VISIBILITY_PUBLIC`, sound/vibration defaults, and iOS `.active` interruption level.

## 0.1.0

- Initial release: local notifications, FCM push display, EventChannel push stream, token retrieval.
- Channel IDs aligned with `doc/INDUSTRY_BENCHMARKS.md`.
