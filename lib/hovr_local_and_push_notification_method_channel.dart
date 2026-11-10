import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hovr_local_and_push_notification/src/constants/channel_names.dart';
import 'package:hovr_local_and_push_notification/src/models/push_notification_event.dart';

import 'hovr_local_and_push_notification_platform_interface.dart';

class MethodChannelHovrLocalAndPushNotification
    extends HovrLocalAndPushNotificationPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(methodChannelName);

  @visibleForTesting
  final eventChannel = const EventChannel(pushEventChannelName);

  @override
  Future<String?> getFcmToken() {
    return methodChannel.invokeMethod<String>(methodGetFcmToken);
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final result = await methodChannel.invokeMethod<bool>(
      methodRequestNotificationPermission,
    );
    return result ?? false;
  }

  @override
  Future<bool> showLocal({
    required String id,
    required String title,
    required String body,
    bool playSound = true,
    int delaySeconds = 1,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      methodShowLocal,
      <String, Object>{
        'id': id,
        'title': title,
        'body': body,
        'playSound': playSound,
        'delaySeconds': delaySeconds,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> scheduleLocal({
    required String id,
    required String title,
    required String body,
    required DateTime fireAt,
    bool playSound = true,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      methodScheduleLocal,
      <String, Object>{
        'id': id,
        'title': title,
        'body': body,
        'playSound': playSound,
        'fireAtEpochMs': fireAt.millisecondsSinceEpoch,
      },
    );
    return result ?? false;
  }

  @override
  Future<void> cancelLocal(String id) {
    return methodChannel.invokeMethod<void>(methodCancelLocal, <String, String>{
      'id': id,
    });
  }

  @override
  Future<void> cancelAllLocal() {
    return methodChannel.invokeMethod<void>(methodCancelAllLocal);
  }

  @override
  Stream<PushNotificationEvent> get pushEvents {
    return eventChannel.receiveBroadcastStream().map((event) {
      if (event is! Map) {
        return const PushNotificationEvent(
          type: PushNotificationEventType.message,
        );
      }
      return PushNotificationEvent.fromMap(event);
    });
  }
}
