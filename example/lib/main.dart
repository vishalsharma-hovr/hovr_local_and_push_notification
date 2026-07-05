import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hovr_local_and_push_notification/hovr_local_and_push_notification.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hovr_local_and_push_notification',
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  final _notifications = HovrLocalAndPushNotification();
  StreamSubscription<PushNotificationEvent>? _pushSubscription;

  String _fcmToken = 'Loading…';
  String _lastPushEvent = 'None';
  String _lastLocalResult = 'Not shown yet';

  @override
  void initState() {
    super.initState();
    _pushSubscription = _notifications.pushEvents.listen((event) {
      if (!mounted) return;
      setState(() {
        _lastPushEvent = '${event.type.name} ${event.messageId ?? ''}'.trim();
      });
    });
    unawaited(_loadFcmToken());
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFcmToken() async {
    final token = await _notifications.getFcmToken();
    if (!mounted) return;
    setState(() {
      _fcmToken = token ?? 'Unavailable (permission or Firebase not ready)';
    });
  }

  Future<void> _showLocalNotification() async {
    final shown = await _notifications.showLocal(
      id: 'example-local',
      title: 'HOVR example',
      body: 'Local notification from the example app.',
    );
    if (!mounted) return;
    setState(() {
      _lastLocalResult = shown ? 'Shown' : 'Not shown (permission denied?)';
    });
  }

  Future<void> _cancelLocalNotification() async {
    await _notifications.cancelLocal('example-local');
    if (!mounted) return;
    setState(() {
      _lastLocalResult = 'Cancelled example-local';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification plugin example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('FCM token: $_fcmToken'),
            const SizedBox(height: 12),
            Text('Last push event: $_lastPushEvent'),
            const SizedBox(height: 12),
            Text('Local notification: $_lastLocalResult'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _showLocalNotification,
              child: const Text('Show local notification'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _cancelLocalNotification,
              child: const Text('Cancel local notification'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadFcmToken,
              child: const Text('Refresh FCM token'),
            ),
          ],
        ),
      ),
    );
  }
}
