import 'dart:io';

import 'package:hovr_local_and_push_notification/src/constants/notification_channels.dart';

void main() {
  final root = Directory.current;
  if (!File('${root.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('Run from packages/hovr_local_and_push_notification');
    exit(1);
  }

  final doc = File('doc/INDUSTRY_BENCHMARKS.md').readAsStringSync();
  final dart = File('lib/src/constants/notification_channels.dart').readAsStringSync();
  final kotlin = File(
    'android/src/main/kotlin/com/hovr/hovr_local_and_push_notification/NotificationChannelIds.kt',
  ).readAsStringSync();
  final swift = File(
    'ios/hovr_local_and_push_notification/Sources/hovr_local_and_push_notification/NotificationLimits.swift',
  ).readAsStringSync();

  var failed = false;
  for (final id in NotificationChannels.allV1) {
    if (!doc.contains('`$id`')) {
      stderr.writeln('Missing in INDUSTRY_BENCHMARKS.md: $id');
      failed = true;
    }
    if (!dart.contains(id)) {
      stderr.writeln('Missing in Dart notification_channels.dart: $id');
      failed = true;
    }
    if (!kotlin.contains(id)) {
      stderr.writeln('Missing in Kotlin NotificationChannelIds.kt: $id');
      failed = true;
    }
    if (!swift.contains(id)) {
      stderr.writeln('Missing in Swift NotificationLimits.swift: $id');
      failed = true;
    }
  }

  if (failed) exit(1);
  stdout.writeln('Industry benchmarks channel IDs OK');
}
