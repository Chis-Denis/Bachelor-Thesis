import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/domain/preferences/dietary_restriction.dart';
import 'package:calorietrack_flutter/domain/preferences/food_allergy.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/allergy_filter.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/budget_filter.dart';
import 'package:calorietrack_flutter/domain/suggestions/filtering/dietary_restriction_filter.dart';

import '../helpers/fakes.dart';

void main() {
  group('AllergyFilter', () {
    const filter = AllergyFilter();

    test('removes an item whose text matches an allergy keyword', () {
      final items = [
        eligible(id: 1, name: 'Peanut satay skewers'),
        eligible(id: 2, name: 'Garden salad'),
      ];
      final safe = filter.apply(items, {FoodAllergy.peanuts});
      expect(safe.map((i) => i.menuItemId), [2]);
    });

    test('isSafe is false for a matching item and true otherwise', () {
      final unsafe = eligible(id: 1, description: 'contains peanut sauce');
      final safe = eligible(id: 2, description: 'tomato and basil');
      expect(filter.isSafe(unsafe, {FoodAllergy.peanuts}), isFalse);
      expect(filter.isSafe(safe, {FoodAllergy.peanuts}), isTrue);
    });

    test('keeps every item when there are no allergies', () {
      final items = [eligible(id: 1, name: 'Peanut bowl'), eligible(id: 2)];
      expect(filter.apply(items, const {}).length, 2);
    });

    test('a peanut-allergic candidate set can never contain a peanut dish', () {
      final items = [
        eligible(id: 1, name: 'Pad thai with peanuts'),
        eligible(id: 2, name: 'Peanut butter shake'),
        eligible(id: 3, name: 'Grilled cod'),
      ];
      final safe = filter.apply(items, {FoodAllergy.peanuts});
      expect(safe.any((i) => i.name.toLowerCase().contains('peanut')), isFalse);
    });
  });

  group('DietaryRestrictionFilter', () {
    const filter = DietaryRestrictionFilter();

    test('keto removes items above the carb ceiling', () {
      final items = [
        eligible(id: 1, name: 'Steak plate', carbs: 8),
        eligible(id: 2, name: 'Pasta bowl', carbs: 65),
      ];
      final allowed = filter.apply(items, {DietaryRestriction.keto});
      expect(allowed.map((i) => i.menuItemId), [1]);
    });

    test('low-carb has a higher ceiling than keto', () {
      final item = eligible(id: 1, name: 'Rice bowl', carbs: 30);
      expect(filter.apply([item], {DietaryRestriction.lowCarb}), isNotEmpty);
      expect(filter.apply([item], {DietaryRestriction.keto}), isEmpty);
    });

    test('vegetarian removes items with meat keywords', () {
      final items = [
        eligible(id: 1, name: 'Beef burger'),
        eligible(id: 2, name: 'Margherita pizza'),
      ];
      final allowed = filter.apply(items, {DietaryRestriction.vegetarian});
      expect(allowed.map((i) => i.menuItemId), [2]);
    });

    test('keeps every item when there are no restrictions', () {
      final items = [
        eligible(id: 1, carbs: 99),
        eligible(id: 2, name: 'Pork ribs')
      ];
      expect(filter.apply(items, const {}).length, 2);
    });
  });

  group('BudgetFilter', () {
    const filter = BudgetFilter();

    test('keeps only items the wallet can afford', () {
      final items = [
        eligible(id: 1, price: 10),
        eligible(id: 2, price: 20),
        eligible(id: 3, price: 25),
      ];
      final affordable = filter.apply(items, 20);
      expect(affordable.map((i) => i.menuItemId), [1, 2]);
    });

    test('an item priced exactly at the balance is affordable', () {
      expect(filter.apply([eligible(id: 1, price: 20)], 20), isNotEmpty);
    });
  });
}
