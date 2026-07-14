import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/preferences/health_goal.dart';
import 'package:calorietrack_flutter/domain/suggestions/goal_guidance.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_meal_suggestion_repository.dart';

import '../helpers/fakes.dart';

void main() {
  group('Goal guidance', () {
    test('every health goal has guidance', () {
      for (final goal in HealthGoal.values) {
        expect(goalGuidance.containsKey(goal), isTrue, reason: goal.name);
      }
    });

    test('muscle gain steers towards protein', () {
      expect(goalGuidance[HealthGoal.gainMuscle], contains('protein'));
    });

    test('weight loss steers towards fewer calories and more fibre', () {
      final text = goalGuidance[HealthGoal.loseWeight]!;
      expect(text, contains('lower-calorie'));
      expect(text, contains('fibre'));
    });

    test('the chosen goal and its guidance are sent to the model', () async {
      final ai = RecordingOpenAi(echoAllEligible);
      final repo = OpenAiMealSuggestionRepository(ai.client);

      await repo.suggest(request(
        items: [eligible(id: 1, protein: 45)],
        goal: HealthGoal.gainMuscle,
      ));

      final payload = ai.lastUserPayload;
      expect(payload['goal'], 'gainMuscle');
      expect(payload['goal_guidance'].toString(), contains('protein'));
    });
  });
}
