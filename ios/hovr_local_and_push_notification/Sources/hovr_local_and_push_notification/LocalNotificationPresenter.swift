import Foundation
import UserNotifications

public enum LocalNotificationPresenter {
    public static func show(
        id: String,
        title: String,
        body: String,
        playSound: Bool = true,
        delaySeconds: Int = 1,
        completion: ((Bool) -> Void)? = nil
    ) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let allowed: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                allowed = true
            default:
                allowed = false
            }
            guard allowed else {
                DispatchQueue.main.async { completion?(false) }
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            if playSound {
                content.sound = .default
            }
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .active
            }
            let delay = max(NotificationLimits.minDelaySeconds, delaySeconds)
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(delay),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                DispatchQueue.main.async {
                    completion?(error == nil)
                }
            }
        }
    }

    public static func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    public static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
