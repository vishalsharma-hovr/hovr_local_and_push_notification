import 'package:hovr_local_and_push_notification/src/models/push_notification_event.dart';

import 'hovr_local_and_push_notification_platform_interface.dart';

export 'src/constants/notification_channels.dart';
export 'src/models/push_notification_event.dart';

class HovrLocalAndPushNotification {
  HovrLocalAndPushNotification({HovrLocalAndPushNotificationPlatform? platform})
      : _platform = platform ?? HovrLocalAndPushNotificationPlatform.instance;

  final HovrLocalAndPushNotificationPlatform _platform;

  Future<String?> getFcmToken() => _platform.getFcmToken();

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

  Future<void> cancelLocal(String id) => _platform.cancelLocal(id);

  Future<void> cancelAllLocal() => _platform.cancelAllLocal();

  Stream<PushNotificationEvent> get pushEvents => _platform.pushEvents;
}
