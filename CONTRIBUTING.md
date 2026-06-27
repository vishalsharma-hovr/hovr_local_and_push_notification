# Contributing

## Setup

```bash
cd packages/hovr_local_and_push_notification
flutter pub get
```

## Before opening a PR

1. Format: `dart format lib test`
2. Analyze: `dart analyze --fatal-warnings lib test`
3. Contract: `dart run tool/check_channel_contract.dart`
4. Benchmarks: `dart run tool/check_industry_benchmarks.dart`
5. Test: `flutter test`
6. Android: `cd example/android && ./gradlew :hovr_local_and_push_notification:testDebugUnitTest`

## Code quality standards

See [doc/CODING_STANDARDS.md](doc/CODING_STANDARDS.md) (10 production rules).

## Channel / API changes

Update Dart (`lib/src/constants/`), Kotlin (`NotificationChannelIds.kt`, `ChannelNames.kt`), Swift (`NotificationLimits.swift`), and document in [CHANNEL_CONTRACT.md](doc/CHANNEL_CONTRACT.md) and [INDUSTRY_BENCHMARKS.md](doc/INDUSTRY_BENCHMARKS.md).

## Publishing to GitHub

```bash
./tool/publish_to_github.sh v0.1.0
```

Requires `brew install gh && gh auth login`.

The script rsyncs this package to a temp clone, pushes a **`release/vX.Y.Z`** branch and the **`vX.Y.Z`** tag, then opens a PR into `main`. The host app can point at the **tag immediately** — merge keeps `main` in sync.

### After publish

Update the host `pubspec.yaml`:

```yaml
hovr_local_and_push_notification:
  git:
    url: https://github.com/vishalsharma-hovr/hovr_local_and_push_notification.git
    ref: v0.1.0
```

Then in the host app: `fvm flutter pub get`, `cd ios && pod install`, full rebuild.
