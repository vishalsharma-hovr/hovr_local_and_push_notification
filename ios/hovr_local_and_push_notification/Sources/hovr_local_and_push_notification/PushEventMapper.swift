import Foundation

enum PushEventMapper {
    static func message(
        title: String?,
        body: String?,
        data: [String: Any],
        messageId: String? = nil
    ) -> [String: Any?] {
        [
            "type": "message",
            "title": title,
            "body": body,
            "data": data,
            "token": nil,
            "messageId": messageId,
        ]
    }

    static func token(_ token: String) -> [String: Any?] {
        [
            "type": "token",
            "title": nil,
            "body": nil,
            "data": [:] as [String: Any],
            "token": token,
            "messageId": nil,
        ]
    }

    static func tap(
        title: String?,
        body: String?,
        data: [String: Any],
        messageId: String? = nil
    ) -> [String: Any?] {
        [
            "type": "tap",
            "title": title,
            "body": body,
            "data": data,
            "token": nil,
            "messageId": messageId,
        ]
    }
}
