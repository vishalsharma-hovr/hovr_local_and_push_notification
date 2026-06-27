import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';

void main() {
  test('PushNotificationEvent.fromMap parses message event', () {
    final event = PushNotificationEvent.fromMap({
      'type': 'message',
      'title': 'Driver arriving',
      'body': 'ETA 3 min',
      'data': {'rideId': 'abc'},
      'messageId': 'm1',
    });
    expect(event.type, PushNotificationEventType.message);
    expect(event.title, 'Driver arriving');
    expect(event.data['rideId'], 'abc');
    expect(event.messageId, 'm1');
  });

  test('PushNotificationEvent.fromMap defaults unknown type to message', () {
    final event = PushNotificationEvent.fromMap({'type': 'unknown'});
    expect(event.type, PushNotificationEventType.message);
  });

  test('PushNotificationEvent.fromMap parses token event', () {
    final event = PushNotificationEvent.fromMap({
      'type': 'token',
      'token': 'abc123',
    });
    expect(event.type, PushNotificationEventType.token);
    expect(event.token, 'abc123');
  });

  test('PushNotificationEvent.fromMap parses tap event', () {
    final event = PushNotificationEvent.fromMap({
      'type': 'tap',
      'data': {'rideId': 'ride-1'},
    });
    expect(event.type, PushNotificationEventType.tap);
    expect(event.data['rideId'], 'ride-1');
  });
}
