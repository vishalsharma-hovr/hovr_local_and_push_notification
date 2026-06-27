enum PushNotificationEventType {
  message,
  token,
  tap;

  static PushNotificationEventType? parse(String? raw) {
    return switch (raw) {
      'message' => PushNotificationEventType.message,
      'token' => PushNotificationEventType.token,
      'tap' => PushNotificationEventType.tap,
      _ => null,
    };
  }

  String get wireValue => name;
}

class PushNotificationEvent {
  const PushNotificationEvent({
    required this.type,
    this.title,
    this.body,
    this.data = const {},
    this.token,
    this.messageId,
  });

  final PushNotificationEventType type;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? token;
  final String? messageId;

  factory PushNotificationEvent.fromMap(Map<dynamic, dynamic> raw) {
    final type = PushNotificationEventType.parse(raw['type'] as String?) ??
        PushNotificationEventType.message;
    final dataRaw = raw['data'];
    final data = dataRaw is Map
        ? Map<String, dynamic>.from(dataRaw)
        : <String, dynamic>{};

    return PushNotificationEvent(
      type: type,
      title: raw['title'] as String?,
      body: raw['body'] as String?,
      data: data,
      token: raw['token'] as String?,
      messageId: raw['messageId'] as String?,
    );
  }
}
