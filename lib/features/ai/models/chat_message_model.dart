/// Chat message representation for the offline GroundBot AI Assistant
class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> groundIds;
  final List<String>? suggestionChips;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.groundIds = const [],
    this.suggestionChips,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'groundIds': groundIds,
      'suggestionChips': suggestionChips,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      groundIds: List<String>.from(json['groundIds'] ?? []),
      suggestionChips: json['suggestionChips'] != null ? List<String>.from(json['suggestionChips']) : null,
    );
  }
}
