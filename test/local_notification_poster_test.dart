import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification_platform_interface.dart';
import 'package:hovr_local_and_push_notification/src/local_notification_poster.dart';
import 'package:hovr_local_and_push_notification/src/models/push_notification_event.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _MockPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements HovrLocalAndPushNotificationPlatform {
  int showLocalCalls = 0;
  int permissionCalls = 0;
  bool permissionGranted = false;
  bool showLocalResult = false;

  @override
  Future<bool> requestNotificationPermission() async {
    permissionCalls++;
    return permissionGranted;
  }

  @override
  Future<bool> showLocal({
    required String id,
    required String title,
    required String body,
    bool playSound = true,
    int delaySeconds = 1,
  }) async {
    showLocalCalls++;
    if (showLocalCalls > 1 && permissionGranted) {
      return true;
    }
    return showLocalResult;
  }

  @override
  Future<String?> getFcmToken() => Future.value(null);

  @override
  Future<void> cancelLocal(String id) async {}

  @override
  Future<void> cancelAllLocal() async {}

  @override
  Stream<PushNotificationEvent> get pushEvents => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockPlatform platform;

  setUp(() {
    platform = _MockPlatform();
    HovrLocalAndPushNotificationPlatform.instance = platform;
  });

  test('postLocal retries after permission grant', () async {
    platform.showLocalResult = false;
    platform.permissionGranted = true;

    final notifications = HovrLocalAndPushNotification(platform: platform);
    final shown = await notifications.postLocal(
      id: 'test_id',
      title: 'Title',
      body: 'Body',
      logTag: 'Test',
    );

    expect(shown, isTrue);
    expect(platform.permissionCalls, 1);
    expect(platform.showLocalCalls, 2);
  });

  test('postHovrLocalNotification skips empty body', () async {
    final shown = await postHovrLocalNotification(
      platform: platform,
      id: 'id',
      title: 'Title',
      body: '   ',
    );

    expect(shown, isFalse);
    expect(platform.showLocalCalls, 0);
  });
}
