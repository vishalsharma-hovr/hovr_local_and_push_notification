import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';

void main() {
  test('NotificationChannels matches industry benchmarks table', () {
    expect(NotificationChannels.rideStatus, 'hovr_ride_status');
    expect(NotificationChannels.ridePromo, 'hovr_ride_promo');
    expect(NotificationChannels.localDefault, 'hovr_local_default');
    expect(NotificationChannels.allV1, hasLength(3));
  });
}
