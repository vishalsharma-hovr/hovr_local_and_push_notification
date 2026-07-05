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
            // Deliver immediately so background suspension does not drop the request.
            let trigger: UNNotificationTrigger? = delay <= NotificationLimits.minDelaySeconds
                ? nil
                : UNTimeIntervalNotificationTrigger(
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

    /// Shows a local notification from an FCM/APNs `userInfo` payload (data-only pushes).
    public static func showFromRemoteUserInfo(_ userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: Any], aps["alert"] != nil {
            return
        }
        let data = userInfo.reduce(into: [String: Any]()) { partial, entry in
            if let key = entry.key as? String {
                partial[key] = entry.value
            }
        }
        let title = data["title"] as? String
        let body = data["body"] as? String
        guard let title, let body, !title.isEmpty, !body.isEmpty else {
            return
        }
        let messageId = data["gcm.message_id"] as? String ?? data["messageId"] as? String
        let id = messageId ?? "fcm_\(UUID().uuidString)"
        show(id: id, title: title, body: body, delaySeconds: NotificationLimits.minDelaySeconds)
    }
}
