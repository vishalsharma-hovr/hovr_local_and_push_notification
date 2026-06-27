import Foundation

enum NotificationLimits {
    static let maxPendingEvents = 32
    static let maxIdLength = 64
    static let maxTitleLength = 128
    static let maxBodyLength = 512
    static let minDelaySeconds = 1
    static let maxDelaySeconds = 3600
}

enum NotificationChannelIds {
    static let rideStatus = "hovr_ride_status"
    static let ridePromo = "hovr_ride_promo"
    static let localDefault = "hovr_local_default"

    static let allV1 = [rideStatus, ridePromo, localDefault]
}

enum ChannelNames {
    static let method = "hovr_local_and_push_notification"
    static let pushEvents = "hovr_local_and_push_notification/push"
}
