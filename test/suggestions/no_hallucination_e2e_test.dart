import 'package:flutter_test/flutter_test.dart';

import 'package:calorietrack_flutter/application/auth/session_store.dart';
import 'package:calorietrack_flutter/application/auth/user_dto.dart';
import 'package:calorietrack_flutter/application/meals/meals_store.dart';
import 'package:calorietrack_flutter/application/suggestions/suggest_meals.dart';
import 'package:calorietrack_flutter/application/suggestions/suggestion_context_builder.dart';
import 'package:calorietrack_flutter/domain/constants/suggestion_constants.dart';
import 'package:calorietrack_flutter/domain/ordering/order.dart';
import 'package:calorietrack_flutter/domain/ordering/order_repository.dart';
import 'package:calorietrack_flutter/domain/preferences/dietary_restriction.dart';
import 'package:calorietrack_flutter/domain/preferences/food_allergy.dart';
import 'package:calorietrack_flutter/domain/preferences/meal_preferences.dart';
import 'package:calorietrack_flutter/domain/preferences/preferences_repository.dart';
import 'package:calorietrack_flutter/domain/restaurants/menu_item.dart';
import 'package:calorietrack_flutter/domain/restaurants/menu_item_with_context.dart';
import 'package:calorietrack_flutter/domain/restaurants/restaurant_repository.dart';
import 'package:calorietrack_flutter/domain/shared/macros.dart';
import 'package:calorietrack_flutter/domain/shared/money.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_meal_suggestion_repository.dart';

import '../helpers/fakes.dart';

void main() {
  List<MenuItemWithContext> catalogue() => [
        _menuItem(1, 'Pad thai with peanuts', carbs: 40, price: 12),
        _menuItem(2, 'Pasta carbonara', carbs: 70, price: 12),
        _menuItem(3, 'Lobster thermidor', carbs: 5, price: 80),
        _menuItem(4, 'Grilled salmon plate', carbs: 4, price: 20),
        _menuItem(5, 'Avocado egg bowl', carbs: 10, price: 15),
      ];

  SessionStore sessionForUser(int userId, double wallet) {
    final session = SessionStore();
    session.set(UserDto(
      id: userId,
      username: 'tester',
      createdAt: DateTime(2026, 1, 1),
      balance: wallet,
      isBusinessOwner: false,
    ));
    return session;
  }

  SuggestionContextBuilder builderWith(SessionStore session) =>
      SuggestionContextBuilder(
        preferences: _FakePreferences(MealPreferences(
          userId: 1,
          dietaryRestrictions: const {DietaryRestriction.keto},
          allergies: const {FoodAllergy.peanuts},
          mealsPerDay: 3,
        )),
        orders: _FakeOrders(),
        restaurants: _FakeRestaurants(catalogue()),
        session: session,
        meals: MealsStore(),
        clock: () => DateTime(2026, 6, 12, 12),
      );

  test('an adversarial model can never put an ineligible dish on the screen',
      () async {
    final session = sessionForUser(1, 30);

    final ai = RecordingOpenAi((_) => modelContent([
          rec(99, restaurantId: 10),
          rec(1, restaurantId: 10),
          rec(2, restaurantId: 10),
          rec(3, restaurantId: 10),
          rec(4, restaurantId: 999),
          {
            'menu_item_id': 4,
            'restaurant_id': 10,
            'reason': 'Lean and within budget',
            'totally_made_up_field': 'ignore me',
          },
          rec(5, restaurantId: 10),
          rec(5, restaurantId: 10),
        ]));

    final useCase = SuggestMeals(
      session,
      builderWith(session),
      OpenAiMealSuggestionRepository(ai.client),
    );

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    final ids = result.data!.map((s) => s.menuItemId).toList();

    expect(ids, [4, 5]);
    expect(ids.toSet().length, ids.length, reason: 'no duplicates');
    expect(
      ids.any((id) => id == 1 || id == 2 || id == 3 || id == 99),
      isFalse,
      reason: 'a filtered or invented dish must never reach the user',
    );
    expect(ids.length,
        lessThanOrEqualTo(SuggestionConstants.defaultRecommendationCount));

    final sent = (ai.lastUserPayload['eligible_items'] as List)
        .cast<Map<String, Object?>>();
    expect(sent.map((m) => m['menu_item_id']).toSet(), {4, 5});
  });

  test('a model that returns only garbage fails cleanly instead of crashing',
      () async {
    final session = sessionForUser(1, 30);
    final ai =
        RecordingOpenAi((_) => modelContent([rec(99, restaurantId: 10)]));

    final useCase = SuggestMeals(
      session,
      builderWith(session),
      OpenAiMealSuggestionRepository(ai.client),
    );

    final result = await useCase.call();

    expect(result.isSuccess, isFalse);
    expect(result.data, isNull);
    expect(result.error, isNotNull);
  });
}

MenuItemWithContext _menuItem(
  int id,
  String name, {
  required double carbs,
  required double price,
}) =>
    MenuItemWithContext(
      restaurantName: 'Test Kitchen',
      cuisine: 'general',
      item: MenuItem(
        id: id,
        restaurantId: 10,
        name: name,
        description: '',
        category: 'Mains',
        price: Money(price),
        macros: Macros(
          calories: 500,
          protein: 20,
          carbs: carbs,
          fat: 15,
          fiber: 5,
          sugar: 0,
        ),
      ),
    );

class _FakePreferences implements PreferencesRepository {
  final MealPreferences _preferences;

  _FakePreferences(this._preferences);

  @override
  Future<MealPreferences?> findByUserId(int userId) async => _preferences;

  @override
  Future<void> save(MealPreferences preferences) async {}
}

class _FakeOrders implements OrderRepository {
  @override
  Future<List<Order>> findByUser(int userId) async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRestaurants implements RestaurantRepository {
  final List<MenuItemWithContext> _catalog;

  _FakeRestaurants(this._catalog);

  @override
  Future<List<MenuItemWithContext>> catalog() async => _catalog;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
