import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../core/constants/api_constants.dart';
import '../../features/ai/models/chat_message_model.dart';
import '../../features/booking/models/booking_model.dart';
import '../../features/customer/models/ground_model.dart';
import '../../features/customer/models/review_model.dart';
import 'ai_repository.dart';

/// Production-grade Gemini AI repository implementing [AiRepository]
/// with graceful fallback to [MockAiRepository] on network or key errors.
class GeminiAiRepository implements AiRepository {
  final MockAiRepository _fallbackMock = MockAiRepository();
  final http.Client _client;

  GeminiAiRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  bool get useRealAi => ApiConstants.hasValidKey;

  @override
  Future<ChatMessageModel> sendChatMessage({
    required String userMessage,
    required List<GroundModel> allGrounds,
  }) async {
    // If no valid key is supplied, directly use intelligent local engine
    if (!ApiConstants.hasValidKey) {
      debugPrint(
        '[GroundBot] No custom Gemini key provided; using local AI engine.',
      );
      return _fallbackMock.sendChatMessage(
        userMessage: userMessage,
        allGrounds: allGrounds,
      );
    }

    try {
      // 1. Prepare Ground Catalog Context for System Prompt
      final catalog = allGrounds.map((g) {
        return {
          'id': g.id,
          'name': g.name,
          'sport': g.sportType.displayName,
          'location': g.location,
          'address': g.address,
          'pricePerHour': g.pricePerHour.toInt(),
          'rating': g.rating,
          'openTime': g.openTime,
          'closeTime': g.closeTime,
        };
      }).toList();

      final systemPrompt =
          '''
You are GroundBot, the AI reservation concierge for GroundZero sports arenas in Pakistan (Islamabad & Rawalpindi).
Below is the database of verified arenas available for booking:
${jsonEncode(catalog)}

Instructions:
1. Recommend relevant arenas based on the user's requested sport, location/city, or budget.
2. Return ONLY a valid JSON object matching this schema:
{
  "reply": "Concise, friendly recommendation text highlighting relevant grounds",
  "groundIds": ["ground_id_1", "ground_id_2"],
  "chips": ["Actionable quick query 1", "Actionable quick query 2"]
}
3. ONLY include groundIds that exist in the database provided.
4. If no arenas match or the query is general/unrelated, provide a polite response with empty groundIds.
''';

      final requestBody = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userMessage},
            ],
          },
        ],
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.4,
        },
      });

      // 2. Perform HTTP POST with 15-second timeout
      final response = await _client
          .post(
            Uri.parse(ApiConstants.geminiBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': ApiConstants.geminiApiKey,
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final rawText = parts.first['text'] as String?;
            if (rawText != null && rawText.isNotEmpty) {
              final jsonResult = jsonDecode(rawText) as Map<String, dynamic>;
              final reply =
                  jsonResult['reply'] as String? ??
                  'Here are some sports grounds you might like:';
              final rawIds = List<String>.from(jsonResult['groundIds'] ?? []);
              final chips = List<String>.from(jsonResult['chips'] ?? []);

              // Validate that groundIds exist in our database
              final validIds = rawIds
                  .where((id) => allGrounds.any((g) => g.id == id))
                  .toList();

              return ChatMessageModel(
                id: const Uuid().v4(),
                text: reply,
                isUser: false,
                timestamp: DateTime.now(),
                groundIds: validIds,
                suggestionChips: chips.isNotEmpty ? chips : null,
              );
            }
          }
        }
      }

      debugPrint(
        '[GroundBot] Gemini API responded with status ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      debugPrint(
        '[GroundBot] Gemini Cloud error, falling back to local engine: $e',
      );
    }

    // Graceful fallback to local pattern engine on any error
    return _fallbackMock.sendChatMessage(
      userMessage: userMessage,
      allGrounds: allGrounds,
    );
  }

  @override
  Future<Map<String, dynamic>> summarizeReviews({
    required GroundModel ground,
    required List<ReviewModel> reviews,
  }) => _fallbackMock.summarizeReviews(ground: ground, reviews: reviews);

  @override
  Future<String> generateGroundDescription({
    required String name,
    required SportType sportType,
    required String location,
    required List<String> facilities,
  }) => _fallbackMock.generateGroundDescription(
    name: name,
    sportType: sportType,
    location: location,
    facilities: facilities,
  );

  @override
  Future<String> generateOwnerInsights({
    required List<BookingModel> bookings,
    required List<GroundModel> grounds,
  }) =>
      _fallbackMock.generateOwnerInsights(bookings: bookings, grounds: grounds);
}
