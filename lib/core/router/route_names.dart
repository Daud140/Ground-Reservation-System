/// Centralized route paths for GroundZero go_router navigation
class AppRoutes {
  AppRoutes._();

  // Public / Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';

  // Customer Module
  static const String customerRoot = '/customer';
  static const String groundDetails = '/customer/ground/:id';
  static const String slotBooking = '/customer/book/:id';
  static const String confirmationTicket = '/customer/ticket/:bookingId';
  static const String aiAssistant = '/customer/ai-assistant';
  static const String groundsMap = '/customer/map';

  // Owner Module
  static const String ownerRoot = '/owner';
}
