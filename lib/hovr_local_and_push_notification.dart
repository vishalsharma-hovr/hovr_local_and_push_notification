import 'package:hovr_local_and_push_notification/src/models/push_notification_event.dart';

import 'hovr_local_and_push_notification_platform_interface.dart';
import 'src/local_notification_poster.dart';

export 'src/constants/notification_channels.dart';
export 'src/local_notification_poster.dart';
export 'src/models/push_notification_event.dart';

class HovrLocalAndPushNotification {
  HovrLocalAndPushNotification({HovrLocalAndPushNotificationPlatform? platform})
    : _platform = platform ?? HovrLocalAndPushNotificationPlatform.instance;

  final HovrLocalAndPushNotificationPlatform _platform;

  Future<String?> getFcmToken() => _platform.getFcmToken();

  Future<bool> requestNotificationPermission() =>
      _platform.requestNotificationPermission();

  Future<bool> showLocal({
    required String id,
    required String title,
    required String body,
    bool playSound = true,
    int delaySeconds = 1,
  }) {
    return _platform.showLocal(
      id: id,
      title: title,
      body: body,
      playSound: playSound,
      delaySeconds: delaySeconds,
    );
  }

  /// Shows a local notification; requests permission and retries once when needed.
  Future<bool> postLocal({
    required String id,
    required String title,
    required String body,
    bool playSound = true,
    int delaySeconds = 1,
    bool requestPermissionOnFailure = true,
    String? logTag,
  }) {
    return postHovrLocalNotification(
      platform: _platform,
      id: id,
      title: title,
      body: body,
      playSound: playSound,
      delaySeconds: delaySeconds,
      requestPermissionOnFailure: requestPermissionOnFailure,
      logTag: logTag,
    );
  }

  /// Schedules a local notification for [fireAt] (survives the app closing
  /// and, on Android, a phone restart). Returns false when notifications are
  /// not allowed, [fireAt] is in the past or more than 30 days ahead, or 64
  /// notifications are already scheduled. `cancelLocal(id)` cancels it.
  Future<bool> scheduleLocal({
    required String id,
    required String title,
    required String body,
    required DateTime fireAt,
    bool playSound = true,
  }) {
    return _platform.scheduleLocal(
      id: id,
      title: title,
      body: body,
      fireAt: fireAt,
      playSound: playSound,
    );
  }

  /// Cancels a shown or scheduled local notification.
  Future<void> cancelLocal(String id) => _platform.cancelLocal(id);

  Future<void> cancelAllLocal() => _platform.cancelAllLocal();

  Stream<PushNotificationEvent> get pushEvents => _platform.pushEvents;
}
