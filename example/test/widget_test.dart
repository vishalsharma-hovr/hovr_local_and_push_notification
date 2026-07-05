import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hovr_local_and_push_notification_example/main.dart';

void main() {
  testWidgets('example home renders plugin controls', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Notification plugin example'), findsOneWidget);
    expect(find.text('Show local notification'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data!.startsWith('FCM token:'),
      ),
      findsOneWidget,
    );
  });
}
