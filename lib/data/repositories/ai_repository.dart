import '../../features/ai/models/chat_message_model.dart';
import '../../features/customer/models/ground_model.dart';
import '../../features/customer/models/review_model.dart';
import '../../features/booking/models/booking_model.dart';

/// Abstract contract for AI features
/// Allows 1-line swap between Offline Mock AI and Real Gemini Cloud AI
abstract class AiRepository {
  bool get useRealAi;

  Future<ChatMessageModel> sendChatMessage({
    required String userMessage,
    required List<GroundModel> allGrounds,
  });

  Future<Map<String, dynamic>> summarizeReviews({
    required GroundModel ground,
    required List<ReviewModel> reviews,
  });

  Future<String> generateGroundDescription({
    required String name,
    required SportType sportType,
    required String location,
    required List<String> facilities,
  });

  Future<String> generateOwnerInsights({
    required List<BookingModel> bookings,
    required List<GroundModel> grounds,
  });
}

/// Offline intelligent pattern matching AI Engine
class MockAiRepository implements AiRepository {
  @override
  final bool useRealAi = false;

  @override
  Future<ChatMessageModel> sendChatMessage({
    required String userMessage,
    required List<GroundModel> allGrounds,
  }) async {
    // Simulate natural AI thinking delay
    await Future.delayed(const Duration(milliseconds: 700));

    final lower = userMessage.toLowerCase();
    List<GroundModel> matched = [];
    String replyText = '';
    List<String> chips = [];

    // 1. Sport identification
    SportType? targetSport;
    if (lower.contains('futsal') || lower.contains('football') || lower.contains('soccer')) {
      targetSport = lower.contains('futsal') ? SportType.futsal : SportType.football;
    } else if (lower.contains('cricket')) {
      targetSport = SportType.cricket;
    } else if (lower.contains('padel')) {
      targetSport = SportType.padel;
    } else if (lower.contains('tennis')) {
      targetSport = SportType.tennis;
    } else if (lower.contains('basketball')) {
      targetSport = SportType.basketball;
    }

    // 2. Budget extraction (e.g. "under 4000", "< 3500", "budget 3000")
    double? budget;
    final budgetRegex = RegExp(r'(?:under|below|less than|<|budget|around)\s*(\d{3,5})');
    final budgetMatch = budgetRegex.firstMatch(lower);
    if (budgetMatch != null) {
      budget = double.tryParse(budgetMatch.group(1)!);
    }

    // 3. Location extraction (Islamabad vs Rawalpindi)
    bool isIslamabad = lower.contains('islamabad') || lower.contains('f-7') || lower.contains('e-11') || lower.contains('f-10') || lower.contains('blue area');
    bool isRawalpindi = lower.contains('rawalpindi') || lower.contains('pindi') || lower.contains('ayub') || lower.contains('chaklala') || lower.contains('bahria');

    // Filter grounds
    matched = allGrounds.where((g) {
      if (targetSport != null && g.sportType != targetSport) return false;
      if (budget != null && g.pricePerHour > budget) return false;
      if (isIslamabad && !g.location.toLowerCase().contains('islamabad')) return false;
      if (isRawalpindi && !g.location.toLowerCase().contains('rawalpindi')) return false;
      return true;
    }).toList();

    // Construct intelligent response
    if (matched.isNotEmpty) {
      final sportName = targetSport?.displayName ?? 'sports';
      final budgetStr = budget != null ? ' within PKR ${budget.toInt()}/hr' : '';
      replyText = 'I found ${matched.length} premier $sportName arena(s)$budgetStr for you in Rawalpindi & Islamabad. Tap any card below to view details and reserve your slot:';
      chips = ['Book Today Evening', 'Show Top Rated', 'Filter by Under 4000 PKR'];
    } else if (targetSport != null) {
      replyText = 'I couldn\'t find available ${targetSport.displayName} grounds matching those specific criteria right now. Here are our top recommended venues:';
      matched = allGrounds.take(2).toList();
      chips = ['View All Grounds', 'Change Budget', 'Top Rated Futsal'];
    } else {
      replyText = 'Hello! I\'m GroundBot, your personal sports ground reservation concierge in Rawalpindi & Islamabad. Tell me what sport you want to play, your location, or your target hourly budget!';
      matched = allGrounds.take(3).toList();
      chips = ['Find Futsal under 3500 PKR', 'Cricket grounds open tomorrow', 'Top rated Padel courts'];
    }

    return ChatMessageModel(
      id: 'ai_msg_${DateTime.now().millisecondsSinceEpoch}',
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      groundIds: matched.map((g) => g.id).toList(),
      suggestionChips: chips,
    );
  }

  @override
  Future<Map<String, dynamic>> summarizeReviews({
    required GroundModel ground,
    required List<ReviewModel> reviews,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final count = reviews.length;
    final rating = ground.rating;

    List<String> pros = [];
    List<String> cons = [];

    // Synthesize realistic pros & cons based on sport and rating
    switch (ground.sportType) {
      case SportType.futsal:
        pros = [
          'High quality synthetic astroturf with shock-absorbing underlayer.',
          'Bright flicker-free LED floodlights for late evening matches.',
          'Convenient on-site changing rooms and sports refreshments.',
        ];
        cons = [
          'High demand during 8 PM - 11 PM prime slots; early reservation advised.',
        ];
        break;
      case SportType.padel:
        pros = [
          'Panoramic Italian glass walls with crystal clear ball visibility.',
          'Well-maintained pro blue turf offering excellent traction.',
          'High-end racket and ball rentals available at the reception.',
        ];
        cons = [
          'Limited weekend evening slot availability without advance booking.',
        ];
        break;
      case SportType.cricket:
        pros = [
          'True-bounce center wicket ideal for both tape ball and hard ball.',
          'Spacious outfield with clear boundary markings.',
          'Traditional pavilion seating for player dugouts and supporters.',
        ];
        cons = [
          'Parking can get busy during major tournament weekends.',
        ];
        break;
      default:
        pros = [
          'Pristine playing surface adhering to international standards.',
          'Friendly and punctual venue staff.',
          'Clean facilities with dedicated locker amenities.',
        ];
        cons = [
          'Peak hours fill up quickly on Friday and Saturday nights.',
        ];
        break;
    }

    return {
      'score': rating,
      'totalReviews': count,
      'summary': 'Players consistently praise ${ground.name} for its ${pros.first.toLowerCase()} Overall customer satisfaction sits at ${(rating / 5 * 100).toInt()}%.',
      'pros': pros,
      'cons': cons,
    };
  }

  @override
  Future<String> generateGroundDescription({
    required String name,
    required SportType sportType,
    required String location,
    required List<String> facilities,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final facilityStr = facilities.isNotEmpty ? facilities.take(4).join(', ') : 'modern amenities';
    return 'Welcome to $name, premier ${sportType.displayName} arena located in $location. Designed for both casual friendlies and intense competitive leagues, the venue features top-tier playing surfaces, full night floodlights, and premium player comfort including $facilityStr. Reserve your slot instantly on GroundZero to experience seamless sports entertainment.';
  }

  @override
  Future<String> generateOwnerInsights({
    required List<BookingModel> bookings,
    required List<GroundModel> grounds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final total = bookings.length;
    final confirmed = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;

    if (total == 0) {
      return 'AI Insight: No bookings logged yet. Promote your ground on social media and ensure floodlight amenities are highlighted to drive evening slot reservations.';
    }

    return 'AI Business Insight: You have $pending pending request(s) and $confirmed confirmed booking(s). 8:00 PM to 10:00 PM slots generate 68% of your weekly revenue. Recommendation: Consider introducing an off-peak discount (before 5:00 PM) to boost daytime ground utilization.';
  }
}
