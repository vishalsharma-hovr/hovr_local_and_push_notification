import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default platform is MethodChannel', () {
    expect(
      MethodChannelHovrLocalAndPushNotification(),
      isA<MethodChannelHovrLocalAndPushNotification>(),
    );
  });
}
