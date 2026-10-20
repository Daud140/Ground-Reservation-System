/// Centralized API constants and environment configuration
class ApiConstants {
  ApiConstants._();

  /// Google Gemini AI API key.
  /// Keys are kept in this constants file or loaded via `--dart-define=GEMINI_API_KEY=...`
  /// Never hardcoded directly into UI screen files.
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDemoGeminiKeyReplaceWithYourOwn',
  );

  /// Gemini REST Endpoint
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
}
