import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_zero/features/auth/screens/onboarding_screen.dart';
import 'package:ground_zero/features/auth/screens/login_screen.dart';
import 'package:ground_zero/features/auth/screens/role_selection_screen.dart';
import 'package:ground_zero/features/customer/screens/customer_home_screen.dart';
import 'package:ground_zero/features/customer/screens/customer_explore_screen.dart';
import 'package:ground_zero/features/customer/screens/ground_detail_screen.dart';
import 'package:ground_zero/features/owner/screens/owner_dashboard_screen.dart';
import 'package:ground_zero/features/booking/screens/slot_booking_screen.dart';
import 'package:ground_zero/features/booking/screens/booking_confirmation_screen.dart';
import 'package:ground_zero/features/ai/screens/ai_assistant_screen.dart';

void main() {
  const phoneSizes = [
    Size(360, 640), // Small phone
    Size(393, 852), // Normal phone (iPhone 14/15/16, modern Android)
    Size(412, 915), // Samsung Galaxy S24 Ultra (tall screen)
  ];

  for (final size in phoneSizes) {
    group('Screen layout tests on ${size.width}x${size.height}', () {
      testWidgets('CustomerHomeScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: CustomerHomeScreen())),
        );
        final exception = tester.takeException();
        if (exception != null) {
          debugPrint('>>> OVERFLOW DETAILS: $exception');
        }
        expect(exception, isNull);
      });

      testWidgets('OwnerDashboardScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OwnerDashboardScreen())),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('OnboardingScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: OnboardingScreen())),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('RoleSelectionScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: RoleSelectionScreen())),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'LoginScreen has no RenderFlex overflow (with normal & large text scaling)',
        (WidgetTester tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(1.1)),
                  child: LoginScreen(),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 500));
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('SlotBookingScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: SlotBookingScreen(groundId: 'ground_1')),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('GroundDetailScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: GroundDetailScreen(groundId: 'ground_1')),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('CustomerExploreScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: CustomerExploreScreen()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('AiAssistantScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: AiAssistantScreen())),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });

      testWidgets('BookingConfirmationScreen has no RenderFlex overflow', (
        WidgetTester tester,
      ) async {
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
