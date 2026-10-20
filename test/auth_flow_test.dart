import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_zero/core/theme/app_theme.dart';
import 'package:ground_zero/data/demo/fake_database.dart';
import 'package:ground_zero/features/auth/models/user_model.dart';
import 'package:ground_zero/features/auth/screens/onboarding_screen.dart';
import 'package:ground_zero/features/auth/screens/role_selection_screen.dart';
import 'package:ground_zero/features/auth/screens/login_screen.dart';

void main() {
  setUp(() {
    FakeDatabase.instance.init();
  });

  group('FakeDatabase & Authentication Unit Tests', () {
    test('Pre-loads customer@groundzero.sport and owner@groundzero.sport with 123456', () {
      final customer = FakeDatabase.instance.authenticate(
        'customer@groundzero.sport',
        '123456',
      );
      expect(customer, isNotNull);
      expect(customer!.role, equals(UserRole.customer));
      expect(customer.email, equals('customer@groundzero.sport'));

      final owner = FakeDatabase.instance.authenticate(
        'owner@groundzero.sport',
        '123456',
      );
      expect(owner, isNotNull);
      expect(owner!.role, equals(UserRole.owner));
      expect(owner.email, equals('owner@groundzero.sport'));
    });

    test('Throws exception on incorrect password', () {
      expect(
        () => FakeDatabase.instance.authenticate(
          'customer@groundzero.sport',
          'wrong_pass',
        ),
        throwsException,
      );
    });
  });

  group('Onboarding Screen Widget Tests', () {
    testWidgets(
      'Renders Skip button, 01/03 page indicator, and Continue GradientButton',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('01/03'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
        expect(find.textContaining('Find nearby turf'), findsOneWidget);
        expect(find.byType(GradientButton), findsOneWidget);
      },
    );
  });

  group('Role Selection Screen Widget Tests', () {
    testWidgets(
      'Renders Step 1 of 3, selectable cards, and updates Continue button text',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 950);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Step 1 of 3'), findsOneWidget);
        expect(find.text('How will you use GroundZero?'), findsOneWidget);
        expect(find.text('I want to play'), findsOneWidget);
        expect(find.text('I own a ground'), findsOneWidget);

        // Initially customer is selected
        expect(find.text('Continue as Player'), findsOneWidget);

        // Scroll and tap owner card
        final ownerCard = find.text('I own a ground');
        await tester.ensureVisible(ownerCard);
        await tester.tap(ownerCard);
        await tester.pumpAndSettle();

        expect(find.text('Continue as Owner'), findsOneWidget);

        // Tap customer card back
        final customerCard = find.text('I want to play');
        await tester.ensureVisible(customerCard);
        await tester.tap(customerCard);
        await tester.pumpAndSettle();

        expect(find.text('Continue as Player'), findsOneWidget);
      },
    );
  });

  group('Login & Sign Up Screen Widget Tests', () {
    testWidgets(
      'Renders toggle, remember me, forgot password, Google button, and fast preview chips',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 1100);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginScreen())),
        );
        await tester.pumpAndSettle();

        // Top header toggle
        expect(find.text('Log In'), findsWidgets);
        expect(find.text('Sign Up'), findsOneWidget);

        // Inputs & options
        expect(find.text('Remember me'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);

        // Fast Preview Demo box
        expect(find.text('Fast Preview Demo'), findsOneWidget);
        expect(find.text('Customer'), findsOneWidget);
        expect(find.text('Arena Owner'), findsOneWidget);

        // Tap Arena Owner demo chip
        final ownerChip = find.text('Arena Owner');
        await tester.ensureVisible(ownerChip);
        await tester.tap(ownerChip);
        await tester.pumpAndSettle();

        // Check filled email
        expect(find.text('owner@groundzero.sport'), findsOneWidget);

        // Tap Customer demo chip
        final customerChip = find.text('Customer');
        await tester.ensureVisible(customerChip);
        await tester.tap(customerChip);
        await tester.pumpAndSettle();

        // Check filled email
        expect(find.text('customer@groundzero.sport'), findsOneWidget);

        // Tap Continue with Google -> triggers coming soon snackbar
        final googleBtn = find.text('Continue with Google');
        await tester.ensureVisible(googleBtn);
        await tester.tap(googleBtn);
        await tester.pump();
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets('Toggles between Log In and Sign Up tabs smoothly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1100);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );
      await tester.pumpAndSettle();

      // Tap Sign Up tab
      final signUpTab = find.text('Sign Up');
      await tester.ensureVisible(signUpTab);
      await tester.tap(signUpTab);
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Account Role'), findsOneWidget);
    });
  });
}
