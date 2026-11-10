/// Canonical channel IDs — must match [doc/INDUSTRY_BENCHMARKS.md].
abstract final class NotificationChannels {
  static const rideStatus = 'hovr_ride_status';
  static const ridePromo = 'hovr_ride_promo';
  static const localDefault = 'hovr_local_default';

  static const allV1 = <String>[rideStatus, ridePromo, localDefault];
}
