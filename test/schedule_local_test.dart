import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification_method_channel.dart';
import 'package:hovr_local_and_push_notification/src/constants/channel_names.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelHovrLocalAndPushNotification();
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });

  test('scheduleLocal sends the fire time as epoch milliseconds', () async {
    final fireAt = DateTime.utc(2026, 11, 10, 14, 30);

    final scheduled = await platform.scheduleLocal(
      id: 'trip_1_2h',
      title: 'Ride soon',
      body: 'Pickup at 4:30 pm',
      fireAt: fireAt,
    );

    expect(scheduled, isTrue);
    expect(calls.single.method, methodScheduleLocal);
    expect(calls.single.arguments, <String, Object>{
      'id': 'trip_1_2h',
      'title': 'Ride soon',
      'body': 'Pickup at 4:30 pm',
      'playSound': true,
      'fireAtEpochMs': fireAt.millisecondsSinceEpoch,
    });
  });

  test('scheduleLocal treats a null reply as not scheduled', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (_) async => null);

    final scheduled = await platform.scheduleLocal(
      id: 'trip_1_1h',
      title: 'Ride soon',
      body: 'Pickup at 4:30 pm',
      fireAt: DateTime.utc(2026, 11, 10, 15, 30),
    );

    expect(scheduled, isFalse);
  });
}
