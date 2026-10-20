/// Centralized API constants and environment configuration
class ApiConstants {
  ApiConstants._();

  // ===========================================================================
  // GEMINI AI CONFIGURATION
  // 1. Obtain an API key from Google AI Studio: https://aistudio.google.com/
  // 2. Either run the app with: flutter run --dart-define=GEMINI_API_KEY="YOUR_KEY"
  //    OR paste your key directly into the placeholder string below:
  // ===========================================================================
  static const String _defaultApiKey = 'PASTE_YOUR_GEMINI_API_KEY_HERE';

  /// Active Gemini API Key (loaded from --dart-define or fallback placeholder)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: _defaultApiKey,
  );

  /// Check if a custom valid API key is present
  static bool get hasValidKey =>
      geminiApiKey.isNotEmpty &&
      geminiApiKey != 'PASTE_YOUR_GEMINI_API_KEY_HERE' &&
      !geminiApiKey.startsWith('AIzaSyDemo');

  /// Gemini REST Endpoint URL for gemini-2.5-flash
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
}
