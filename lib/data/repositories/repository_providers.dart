import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'ground_repository.dart';
import 'booking_repository.dart';
import 'review_repository.dart';
import 'ai_repository.dart';

// =============================================================================
// RIVERPOD REPOSITORY PROVIDERS
// To switch to Firebase / Cloud backend in the Final Term, replace the Mock
// implementation below with the Firebase implementation in ONE LINE.
// =============================================================================

/// Provides the active AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(); // Replace with FirebaseAuthRepository() for Firebase backend
});

/// Provides the active GroundRepository implementation
final groundRepositoryProvider = Provider<GroundRepository>((ref) {
  return MockGroundRepository(); // Replace with FirebaseGroundRepository() for Firebase backend
});

/// Provides the active BookingRepository implementation
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return MockBookingRepository(); // Replace with FirebaseBookingRepository() for Firebase backend
});

/// Provides the active ReviewRepository implementation
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return MockReviewRepository(); // Replace with FirebaseReviewRepository() for Firebase backend
});

/// Provides the active AiRepository implementation
final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return MockAiRepository(); // Replace with GeminiCloudAiRepository() if calling real Gemini API
});
