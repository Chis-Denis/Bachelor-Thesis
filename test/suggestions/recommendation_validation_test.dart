import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/shared/failures.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_meal_suggestion_repository.dart';

import '../helpers/fakes.dart';

void main() {
  group('Recommendation validation', () {
    final items = [
      eligible(id: 1, restaurantId: 10, name: 'Chicken bowl'),
      eligible(id: 2, restaurantId: 10, name: 'Salmon poke'),
      eligible(id: 3, restaurantId: 10, name: 'Quinoa salad'),
    ];

    test('drops a hallucinated id that is not in the eligible set', () async {
      final ai = RecordingOpenAi((_) => modelContent([
            rec(99, restaurantId: 10),
            rec(2, restaurantId: 10),
          ]));
      final repo = OpenAiMealSuggestionRepository(ai.client);

      final result = await repo.suggest(request(items: items));

      expect(result.map((s) => s.menuItemId), [2]);
    });

    test('drops an id pointing at the wrong restaurant', () async {
      final ai = RecordingOpenAi((_) => modelContent([
            rec(1, restaurantId: 999),
            rec(3, restaurantId: 10),
          ]));
      final repo = OpenAiMealSuggestionRepository(ai.client);

      final result = await repo.suggest(request(items: items));

      expect(result.map((s) => s.menuItemId), [3]);
    });

    test('keeps only the first of repeated ids', () async {
      final ai = RecordingOpenAi((_) => modelContent([
            rec(2, restaurantId: 10),
            rec(2, restaurantId: 10),
            rec(3, restaurantId: 10),
          ]));
      final repo = OpenAiMealSuggestionRepository(ai.client);

      final result = await repo.suggest(request(items: items));

      expect(result.map((s) => s.menuItemId), [2, 3]);
    });

    test('never returns more than the requested count', () async {
      final many = [
        for (var i = 1; i <= 6; i++) eligible(id: i, restaurantId: 10)
      ];
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);

      final result = await repo.suggest(request(items: many, count: 4));

      expect(result, hasLength(4));
    });

    test('clamps an over-long reason to the maximum length', () async {
      final longReason = 'protein ' * 40;
      final ai = RecordingOpenAi((_) => modelContent([
            rec(1, restaurantId: 10, reason: longReason),
          ]));
      final repo = OpenAiMealSuggestionRepository(ai.client);

      final result = await repo.suggest(request(items: items));

      expect(result.single.reason.length, lessThanOrEqualTo(90));
    });

    test('throws when the model returns no usable item', () async {
      final ai =
          RecordingOpenAi((_) => modelContent([rec(99, restaurantId: 10)]));
      final repo = OpenAiMealSuggestionRepository(ai.client);

      expect(
        () => repo.suggest(request(items: items)),
        throwsA(isA<SuggestionFailure>()),
      );
    });

    test('throws when the response shape is malformed', () async {
      final ai = RecordingOpenAi((_) => '{"unexpected": true}');
      final repo = OpenAiMealSuggestionRepository(ai.client);

      expect(
        () => repo.suggest(request(items: items)),
        throwsA(isA<SuggestionFailure>()),
      );
    });
  });
}
