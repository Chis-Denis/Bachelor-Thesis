import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/preferences/dietary_restriction.dart';
import 'package:calorietrack_flutter/domain/preferences/food_allergy.dart';
import 'package:calorietrack_flutter/domain/suggestions/eligible_menu_item.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/allergy_filter.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/budget_filter.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/dietary_restriction_filter.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_meal_suggestion_repository.dart';

import '../helpers/fakes.dart';

List<EligibleMenuItem> applyFilters(
  List<EligibleMenuItem> items, {
  required Set<FoodAllergy> allergies,
  required Set<DietaryRestriction> diets,
  required double wallet,
}) {
  var pool = const AllergyFilter().apply(items, allergies);
  pool = const DietaryRestrictionFilter().apply(pool, diets);
  pool = const BudgetFilter().apply(pool, wallet);
  return pool;
}

void main() {
  test('constraints survive the whole pipeline even if the model misbehaves',
      () async {
    final catalogue = [
      eligible(
          id: 1,
          restaurantId: 10,
          name: 'Pad thai with peanuts',
          carbs: 40,
          price: 12),
      eligible(
          id: 2,
          restaurantId: 10,
          name: 'Pasta carbonara',
          carbs: 70,
          price: 12),
      eligible(
          id: 3,
          restaurantId: 10,
          name: 'Lobster thermidor',
          carbs: 5,
          price: 80),
      eligible(
          id: 4,
          restaurantId: 10,
          name: 'Grilled salmon plate',
          carbs: 4,
          price: 20),
      eligible(
          id: 5,
          restaurantId: 10,
          name: 'Avocado egg bowl',
          carbs: 10,
          price: 15),
    ];

    final pool = applyFilters(
      catalogue,
      allergies: {FoodAllergy.peanuts},
      diets: {DietaryRestriction.keto},
      wallet: 30,
    );

    expect(pool.map((i) => i.menuItemId).toSet(), {4, 5});

    final ai = RecordingOpenAi((_) => modelContent([
          rec(1, restaurantId: 10),
          rec(2, restaurantId: 10),
          rec(4, restaurantId: 10),
          rec(5, restaurantId: 10),
        ]));
    final repo = OpenAiMealSuggestionRepository(ai.client);

    final result = await repo.suggest(request(
      items: pool,
      allergies: {FoodAllergy.peanuts},
      diets: {DietaryRestriction.keto},
      wallet: 30,
    ));

    final ids = result.map((s) => s.menuItemId).toSet();
    expect(ids.every((id) => id == 4 || id == 5), isTrue);
    expect(ids.contains(1), isFalse,
        reason: 'the peanut dish must never reach the user');
    expect(ids.contains(2), isFalse,
        reason: 'the keto violation must never reach the user');
    for (final s in result) {
      expect(s.itemName.toLowerCase().contains('peanut'), isFalse);
    }
  });
}
