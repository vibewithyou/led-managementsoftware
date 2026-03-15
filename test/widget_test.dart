import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:led_management_software/app/app.dart';

void main() {
  testWidgets('App boots into dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LedControlApp());
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Broadcast Dashboard'), findsOneWidget);
  });
}
