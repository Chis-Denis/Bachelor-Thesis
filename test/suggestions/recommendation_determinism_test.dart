import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/preferences/health_goal.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_meal_suggestion_repository.dart';

import '../helpers/fakes.dart';

void main() {
  group('Recommendation determinism', () {
    final items = [
      eligible(id: 1, name: 'Grilled chicken bowl', protein: 45),
      eligible(id: 2, name: 'Salmon poke', protein: 38),
      eligible(id: 3, name: 'Quinoa salad', protein: 18),
    ];

    test('the model is called with temperature 0 and the fixed model id',
        () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);

      await repo.suggest(request(items: items, goal: HealthGoal.gainMuscle));

      expect(ai.bodies.single['temperature'], 0);
      expect(ai.bodies.single['model'], 'gpt-4o-2024-08-06');
    });

    test('the same request produces the same seed every time', () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);
      final req =
          request(items: items, goal: HealthGoal.gainMuscle, wallet: 100);

      await repo.suggest(req);
      await repo.suggest(req);

      expect(ai.bodies, hasLength(2));
      expect(ai.bodies[0]['seed'], ai.bodies[1]['seed']);
    });

    test('the same request produces an identical result every time', () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);
      final req = request(items: items, goal: HealthGoal.gainMuscle);

      final first = await repo.suggest(req);
      final second = await repo.suggest(req);

      expect(
        first.map((s) => '${s.menuItemId}:${s.reason}'),
        second.map((s) => '${s.menuItemId}:${s.reason}'),
      );
    });

    test('a different context yields a different seed', () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);

      await repo.suggest(request(items: items, wallet: 100));
      await repo.suggest(request(items: items, wallet: 40));

      expect(ai.bodies[0]['seed'], isNot(ai.bodies[1]['seed']));
    });

    test('calories consumed today also move the seed', () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);

      await repo.suggest(request(items: items, caloriesToday: 0));
      await repo.suggest(request(items: items, caloriesToday: 1200));

      expect(ai.bodies[0]['seed'], isNot(ai.bodies[1]['seed']));
    });
  });
}
