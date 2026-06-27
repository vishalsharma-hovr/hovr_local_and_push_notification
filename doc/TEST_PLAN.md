# Test plan

## Automated

```bash
cd packages/hovr_local_and_push_notification
flutter test
dart analyze --fatal-warnings lib test
dart run tool/check_channel_contract.dart
dart run tool/check_industry_benchmarks.dart
cd android && ./gradlew :hovr_local_and_push_notification:testDebugUnitTest
```

## Manual

| # | Scenario | Expected |
|---|----------|----------|
| 1 | `showLocal` granted | Banner visible |
| 2 | `showLocal` denied | Returns `false` |
| 3 | `cancelLocal` | Removed |
| 4 | FCM foreground | Banner + pushEvents |
| 5 | FCM background tap | App opens + tap event |
| 6 | `getFcmToken` iOS device | Non-null after permission |
| 7 | Location tracking | One banner per session |
| 8 | Token refresh | pushEvents `token` |
| 9 | Data-only FCM | Title/body from data |
| 10 | Terminated tap | `getInitialMessage` routes |
