import 'dart:io';

import 'package:hovr_local_and_push_notification/src/constants/channel_names.dart';

void main() {
  final root = Directory.current;
  if (!File('${root.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('Run from packages/hovr_local_and_push_notification');
    exit(1);
  }

  const pairs = <(String, String)>[
    (methodChannelName, 'ChannelNames.METHOD'),
    (pushEventChannelName, 'ChannelNames.PUSH_EVENTS'),
    (methodGetFcmToken, 'getFcmToken'),
    (methodShowLocal, 'showLocal'),
    (methodCancelLocal, 'cancelLocal'),
    (methodCancelAllLocal, 'cancelAllLocal'),
    (methodRequestNotificationPermission, 'requestNotificationPermission'),
  ];

  final dartChannel = File('lib/src/constants/channel_names.dart').readAsStringSync();
  final dartMethods = File('lib/hovr_local_and_push_notification_method_channel.dart').readAsStringSync();
  final kotlin = File(
    'android/src/main/kotlin/com/hovr/hovr_local_and_push_notification/HovrLocalAndPushNotificationPlugin.kt',
  ).readAsStringSync();
  final kotlinChannels = File(
    'android/src/main/kotlin/com/hovr/hovr_local_and_push_notification/ChannelNames.kt',
  ).readAsStringSync();
  final kotlinSources = '$kotlin$kotlinChannels';
  final swiftPlugin = File(
    'ios/hovr_local_and_push_notification/Sources/hovr_local_and_push_notification/HovrLocalAndPushNotificationPlugin.swift',
  ).readAsStringSync();
  final swiftLimits = File(
    'ios/hovr_local_and_push_notification/Sources/hovr_local_and_push_notification/NotificationLimits.swift',
  ).readAsStringSync();
  final swift = '$swiftPlugin$swiftLimits';

  var failed = false;
  for (final (wire, _) in pairs) {
    if (!dartChannel.contains("'$wire'") && !dartMethods.contains("'$wire'")) {
      stderr.writeln('Missing in Dart: $wire');
      failed = true;
    }
    if (!kotlinSources.contains('"$wire"') && !kotlinSources.contains("'$wire'")) {
      stderr.writeln('Missing in Kotlin: $wire');
      failed = true;
    }
    if (!swift.contains('"$wire"')) {
      stderr.writeln('Missing in Swift: $wire');
      failed = true;
    }
  }

  if (failed) exit(1);
  stdout.writeln('Channel contract OK');
}
