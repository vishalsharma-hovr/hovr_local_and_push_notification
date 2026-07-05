import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin method channel smoke test', (WidgetTester tester) async {
    final plugin = HovrLocalAndPushNotification();

    final token = await plugin.getFcmToken();
    expect(token, isA<String?>());

    final shown = await plugin.showLocal(
      id: 'integration-test',
      title: 'Integration test',
      body: 'Smoke test notification',
    );
    expect(shown, isA<bool>());

    await plugin.cancelLocal('integration-test');
    await plugin.cancelAllLocal();
  });

  testWidgets('pushEvents stream attaches', (WidgetTester tester) async {
    final plugin = HovrLocalAndPushNotification();
    final subscription = plugin.pushEvents.listen((_) {});
    addTearDown(subscription.cancel);
  });
}
