# Coding standards

| # | Rule | Enforcement |
|---|------|-------------|
| 1 | Simple control flow | Early return; max 3 nesting levels |
| 2 | Bounded buffers | `NotificationLimits.maxPendingEvents = 32`, `maxIdRegistry = 64` |
| 3 | Limit allocation | Notification channels created once on attach |
| 4 | Functions ≤ ~60 lines | Split Plugin / Presenter / Mapper |
| 5 | Tests | Dart + JUnit for registry and event parsing |
| 6 | Smallest scope | Weak refs on iOS; no app-wide singletons except plugin bridge |
| 7 | Check return values | Stable error codes on channels |
| 8 | API guards | SDK 33+ in `NotificationPermissionGate` only |
| 9 | Reference safety | `[weak self]` / nullable activity |
| 10 | Zero warnings | `dart analyze --fatal-warnings` clean |

Forbidden: log FCM/APNs tokens in release; duplicate permission prompts; unbounded pending buffers.
