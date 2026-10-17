import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_zero/features/auth/screens/onboarding_screen.dart';
import 'package:ground_zero/features/auth/screens/login_screen.dart';
import 'package:ground_zero/features/customer/screens/customer_home_screen.dart';
import 'package:ground_zero/features/owner/screens/owner_dashboard_screen.dart';
import 'package:ground_zero/features/booking/screens/booking_confirmation_screen.dart';

void main() {
  const phoneSizes = [
    Size(360, 800), // Standard Android
    Size(375, 812), // iPhone SE / Mini
    Size(390, 844), // iPhone 13/14
    Size(412, 915), // Pixel / Large Android
  ];

  for (final size in phoneSizes) {
    group('Screen layout tests at width ${size.width}', () {
      testWidgets('CustomerHomeScreen has no RenderFlex overflow', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CustomerHomeScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        // expect null but let's see what overflows
        final exception = tester.takeException();
        if (exception != null) {
          debugPrint('OVERFLOW DETAILS:\n${exception.toString()}');
          if (exception is FlutterError) {
            debugPrint(exception.toStringDeep());
          }
        }
        expect(exception, isNull);
      });

      testWidgets('OwnerDashboardScreen has no RenderFlex overflow', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OwnerDashboardScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('OnboardingScreen has no RenderFlex overflow', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OnboardingScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('LoginScreen has no RenderFlex overflow', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('BookingConfirmationScreen has no RenderFlex overflow', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: BookingConfirmationScreen(bookingId: 'GZ-789254'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });
    });
  }
}
