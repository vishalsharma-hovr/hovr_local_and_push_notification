import 'package:hovr_local_and_push_notification/src/models/push_notification_event.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hovr_local_and_push_notification_method_channel.dart';

abstract class HovrLocalAndPushNotificationPlatform extends PlatformInterface {
  HovrLocalAndPushNotificationPlatform() : super(token: _token);

  static final Object _token = Object();

  static HovrLocalAndPushNotificationPlatform _instance =
      MethodChannelHovrLocalAndPushNotification();

  static HovrLocalAndPushNotificationPlatform get instance => _instance;

  static set instance(HovrLocalAndPushNotificationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getFcmToken();

  Future<bool> showLocal({
    required String id,
    required String title,
    required String body,
    bool playSound = true,
    int delaySeconds = 1,
  });

  Future<void> cancelLocal(String id);

  Future<void> cancelAllLocal();

  Stream<PushNotificationEvent> get pushEvents {
    throw UnimplementedError('pushEvents has not been implemented.');
  }
}
