import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ground_reservation_system/main.dart';

void main() {
  testWidgets('Ground Reservation System Login UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GroundReservationApp());

    // Verify that title and Login UI components are present.
    expect(find.text('Ground Reservation System'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Auto-fill Demo Credentials'), findsOneWidget);
  });
}
