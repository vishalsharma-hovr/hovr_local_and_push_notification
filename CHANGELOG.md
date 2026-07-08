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
