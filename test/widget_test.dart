import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ground_zero/main.dart';
import 'package:ground_zero/data/demo/demo_data.dart';
import 'package:ground_zero/data/repositories/ai_repository.dart';

void main() {
  testWidgets('GroundZeroApp initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GroundZeroApp()));

    expect(find.byType(GroundZeroApp), findsOneWidget);
  });

  test('DemoData contains Pakistani sports grounds & users', () {
    expect(DemoData.grounds.length, greaterThanOrEqualTo(8));
    expect(DemoData.users.length, greaterThanOrEqualTo(5));
    expect(DemoData.grounds.first.name, contains('Rawal Sports Arena'));
  });

  test('AiRepository generates intelligent ground recommendations', () async {
    final aiRepo = MockAiRepository();
    final grounds = DemoData.grounds;

    final response = await aiRepo.sendChatMessage(
      userMessage: 'Looking for 5-a-side futsal in Islamabad under 4000',
      allGrounds: grounds,
    );

    expect(response.isUser, isFalse);
    expect(response.text, isNotEmpty);
    expect(response.groundIds, isNotEmpty);
  });
}
