import 'dart:developer';

import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification_platform_interface.dart';

/// Posts a local OS notification and optionally requests permission before retrying.
Future<bool> postHovrLocalNotification({
  required HovrLocalAndPushNotificationPlatform platform,
  required String id,
  required String title,
  required String body,
  bool playSound = true,
  int delaySeconds = 1,
  bool requestPermissionOnFailure = true,
  String? logTag,
}) async {
  final tag = logTag ?? 'HovrLocalNotification';
  final trimmedTitle = title.trim();
  final trimmedBody = body.trim();
  if (trimmedTitle.isEmpty || trimmedBody.isEmpty) {
    log(name: tag, 'Skipped: empty title or body');
    return false;
  }

  Future<bool> attempt() async {
    try {
      return await platform.showLocal(
        id: id,
        title: trimmedTitle,
        body: trimmedBody,
        playSound: playSound,
        delaySeconds: delaySeconds,
      );
    } catch (error, stackTrace) {
      log(name: tag, 'showLocal failed', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  var shown = await attempt();
  if (!shown && requestPermissionOnFailure) {
    log(name: tag, 'showLocal returned false — requesting notification permission');
    final granted = await platform.requestNotificationPermission();
    if (granted) {
      shown = await attempt();
    }
  }

  if (!shown) {
    log(name: tag, 'Local notification was not displayed');
  }

  return shown;
}
