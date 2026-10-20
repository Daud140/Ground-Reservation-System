import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/customer/screens/customer_main_shell.dart';
import '../../features/customer/screens/ground_detail_screen.dart';
import '../../features/booking/screens/slot_booking_screen.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/booking/models/booking_model.dart';
import '../../features/ai/screens/ai_assistant_screen.dart';
import '../../features/customer/screens/grounds_map_screen.dart';
import '../../features/owner/screens/owner_main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authState.isAuthenticated;
      final currentPath = state.uri.path;

      // Allow public routes
      final isPublic =
          currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.onboarding ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.roleSelection;

      // If not logged in and attempting private route, allow demo browsing or redirect
      if (!isAuth && !isPublic) {
        return AppRoutes.login;
      }

      // If on root splash, route to app if authenticated, otherwise to onboarding
      if (currentPath == AppRoutes.splash) {
        if (isAuth) {
          return authState.isOwner
              ? AppRoutes.ownerRoot
              : AppRoutes.customerRoot;
        }
        return AppRoutes.onboarding;
      }

      // Role security: Customers cannot reach owner screens, owners cannot reach customer screens
      if (isAuth) {
        if (!authState.isOwner && currentPath.startsWith(AppRoutes.ownerRoot)) {
          return AppRoutes.customerRoot;
        }
        if (authState.isOwner &&
            currentPath.startsWith(AppRoutes.customerRoot)) {
          return AppRoutes.ownerRoot;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          final initialRole = roleParam == 'owner'
              ? UserRole.owner
              : UserRole.customer;
          final tabParam = state.uri.queryParameters['tab'];
          final isLogin = tabParam != 'signup';
          return LoginScreen(initialRole: initialRole, initialIsLogin: isLogin);
        },
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerRoot,
        builder: (context, state) => const CustomerMainShell(),
      ),
      GoRoute(
        path: AppRoutes.groundDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'ground_1';
          return GroundDetailScreen(groundId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.slotBooking,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'ground_1';
          return SlotBookingScreen(groundId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.confirmationTicket,
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId'] ?? 'GZ-789254';
          final bookingExtra = state.extra as BookingModel?;
          return BookingConfirmationScreen(
            bookingId: bookingId,
            bookingExtra: bookingExtra,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: AppRoutes.groundsMap,
        builder: (context, state) => const GroundsMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerRoot,
        builder: (context, state) => const OwnerMainShell(),
      ),
    ],
  );
});
