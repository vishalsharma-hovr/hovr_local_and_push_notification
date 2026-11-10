import FirebaseCore
import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

public class HovrLocalAndPushNotificationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
    UNUserNotificationCenterDelegate, MessagingDelegate
{
    private let pushBuffer = PushEventBuffer()
    private var foregroundPresentationEnabled = true

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = HovrLocalAndPushNotificationPlugin()
        let channel = FlutterMethodChannel(
            name: ChannelNames.method,
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(
            name: ChannelNames.pushEvents,
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)

        UNUserNotificationCenter.current().delegate = instance
        Messaging.messaging().delegate = instance
        shared = instance
    }

    public static weak var shared: HovrLocalAndPushNotificationPlugin?

    public static func setApnsToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getFcmToken":
            getFcmToken(result: result)
        case "requestNotificationPermission":
            requestNotificationPermission(result: result)
        case "showLocal":
            showLocal(call: call, result: result)
        case "scheduleLocal":
            scheduleLocal(call: call, result: result)
        case "cancelLocal":
            cancelLocal(call: call, result: result)
        case "cancelAllLocal":
            LocalNotificationPresenter.cancelAll()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        pushBuffer.attach(events)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        pushBuffer.detach()
        return nil
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        pushBuffer.emit(PushEventMapper.token(fcmToken))
    }

    public func messaging(_ messaging: Messaging, didReceive remoteMessage: [AnyHashable: Any]) {
        emitUserInfo(remoteMessage, type: "message")
        LocalNotificationPresenter.showFromRemoteUserInfo(remoteMessage)
    }

    public static func showLocalNotificationFromRemoteUserInfo(_ userInfo: [AnyHashable: Any]) {
        LocalNotificationPresenter.showFromRemoteUserInfo(userInfo)
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        emitUserInfo(userInfo, type: "message")
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        emitUserInfo(response.notification.request.content.userInfo, type: "tap")
        completionHandler()
    }

    private func getFcmToken(result: @escaping FlutterResult) {
        if FirebaseApp.app() == nil {
            result(FlutterError(
                code: "FIREBASE_NOT_INITIALIZED",
                message: "Firebase is not initialized in the host app.",
                details: nil
            ))
            return
        }
        Messaging.messaging().token { token, error in
            if let error {
                result(FlutterError(
                    code: "FCM_ERROR",
                    message: "Failed to get FCM token",
                    details: error.localizedDescription
                ))
                return
            }
            result(token)
        }
    }

    private func requestNotificationPermission(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if let error {
                result(FlutterError(
                    code: "NOTIFICATION_PERMISSION_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
                return
            }
            result(granted)
        }
    }

    private func showLocal(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String, !id.isEmpty,
              let title = args["title"] as? String, !title.isEmpty,
              let body = args["body"] as? String, !body.isEmpty
        else {
            result(FlutterError(code: "MISSING_ARG", message: "id, title, and body are required", details: nil))
            return
        }
        if id.count > NotificationLimits.maxIdLength ||
            title.count > NotificationLimits.maxTitleLength ||
            body.count > NotificationLimits.maxBodyLength
        {
            result(FlutterError(code: "INVALID_ARG", message: "Argument length exceeded", details: nil))
            return
        }
        let playSound = args["playSound"] as? Bool ?? true
        let delaySeconds = min(
            max(args["delaySeconds"] as? Int ?? NotificationLimits.minDelaySeconds, NotificationLimits.minDelaySeconds),
            NotificationLimits.maxDelaySeconds
        )
        LocalNotificationPresenter.show(
            id: id,
            title: title,
            body: body,
            playSound: playSound,
            delaySeconds: delaySeconds
        ) { success in
            result(success)
        }
    }

    private func scheduleLocal(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String, !id.isEmpty,
              let title = args["title"] as? String, !title.isEmpty,
              let body = args["body"] as? String, !body.isEmpty,
              let fireAtMs = (args["fireAtEpochMs"] as? NSNumber)?.doubleValue
        else {
            result(FlutterError(
                code: "MISSING_ARG",
                message: "id, title, body, and fireAtEpochMs are required",
                details: nil
            ))
            return
        }
        if id.count > NotificationLimits.maxIdLength ||
            title.count > NotificationLimits.maxTitleLength ||
            body.count > NotificationLimits.maxBodyLength
        {
            result(FlutterError(code: "INVALID_ARG", message: "Argument length exceeded", details: nil))
            return
        }
        LocalNotificationPresenter.schedule(
            id: id,
            title: title,
            body: body,
            fireAt: Date(timeIntervalSince1970: fireAtMs / 1000),
            playSound: args["playSound"] as? Bool ?? true
        ) { success in
            result(success)
        }
    }

    private func cancelLocal(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String, !id.isEmpty
        else {
            result(FlutterError(code: "MISSING_ARG", message: "id is required", details: nil))
            return
        }
        LocalNotificationPresenter.cancel(id: id)
        result(nil)
    }

    private func emitUserInfo(_ userInfo: [AnyHashable: Any], type: String) {
        let data = userInfo.reduce(into: [String: Any]()) { partial, entry in
            if let key = entry.key as? String {
                partial[key] = entry.value
            }
        }
        let title = data["title"] as? String ?? (userInfo["title"] as? String)
        let body = data["body"] as? String ?? (userInfo["body"] as? String)
        let messageId = data["gcm.message_id"] as? String ?? data["messageId"] as? String
        let event: [String: Any?]
        if type == "tap" {
            event = PushEventMapper.tap(title: title, body: body, data: data, messageId: messageId)
        } else {
            event = PushEventMapper.message(title: title, body: body, data: data, messageId: messageId)
        }
        pushBuffer.emit(event)
    }
}
