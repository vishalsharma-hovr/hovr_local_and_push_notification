# Host migration from `hovr_notification`

## Checklist

| Step | Action | HOVR rider status |
|------|--------|-------------------|
| 1 | Add dependency (path or git) | Done — `path: packages/hovr_local_and_push_notification` |
| 2 | Remove git `hovr_notification` | Done |
| 3 | Replace `import 'package:hovr_notification/...'` | Done |
| 4 | Replace `HovrNotification()` → `HovrLocalAndPushNotification()` | Done — `lib/splash_screen.dart` |
| 5 | Add `pushEvents.listen` + cold-start FCM | Done — splash |
| 6 | Forward APNs token in `AppDelegate` | Done |
| 7 | Remove `registerApnsTokenChannel` | Done |
| 8 | Wire `LocationUpdatesService` to `LocalNotificationPresenter` | Done |
| 9 | Re-register token on login/logout | Host backend responsibility |
| 10 | Run [TEST_PLAN.md](TEST_PLAN.md) | Automated green; manual iOS device QA pending |

## After publishing to GitHub

Switch host `pubspec.yaml` from path to git:

```yaml
hovr_local_and_push_notification:
  git:
    url: https://github.com/vishalsharma-hovr/hovr_local_and_push_notification.git
    ref: v0.1.0
```

Publish from the package directory:

```bash
cd packages/hovr_local_and_push_notification
./tool/publish_to_github.sh v0.1.0
```

## Do not repeat (legacy plugin audit)

- EventChannel was never registered on iOS
- Android used `invokeMethod("onPushEvent")` instead of EventChannel
- APNs token not forwarded to Firebase Messaging
- Duplicate permission prompts vs `hovr_device_permissions`
