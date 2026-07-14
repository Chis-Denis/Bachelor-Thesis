import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:calorietrack_flutter/domain/preferences/dietary_restriction.dart';
import 'package:calorietrack_flutter/domain/preferences/food_allergy.dart';
import 'package:calorietrack_flutter/domain/preferences/health_goal.dart';
import 'package:calorietrack_flutter/domain/suggestions/eligible_menu_item.dart';
import 'package:calorietrack_flutter/domain/suggestions/suggestion_request.dart';
import 'package:calorietrack_flutter/infrastructure/remote/openai_client.dart';

EligibleMenuItem eligible({
  required int id,
  int restaurantId = 1,
  String restaurantName = 'Test Kitchen',
  String cuisine = 'general',
  String name = 'Dish',
  String category = 'Mains',
  String description = '',
  double price = 10,
  double calories = 500,
  double protein = 20,
  double carbs = 50,
  double fat = 15,
  double fiber = 5,
}) {
  return EligibleMenuItem(
    menuItemId: id,
    restaurantId: restaurantId,
    restaurantName: restaurantName,
    cuisine: cuisine,
    name: name,
    category: category,
    description: description,
    price: price,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
  );
}

SuggestionRequest request({
  required List<EligibleMenuItem> items,
  int userId = 1,
  Set<FoodAllergy> allergies = const {},
  Set<DietaryRestriction> diets = const {},
  HealthGoal? goal,
  int? calorieTarget,
  int mealsPerDay = 3,
  double wallet = 100,
  double caloriesToday = 0,
  double proteinToday = 0,
  double carbsToday = 0,
  double fatToday = 0,
  List<String> recentNames = const [],
  List<String> recentCuisines = const [],
  int count = 4,
}) {
  return SuggestionRequest(
    userId: userId,
    allergies: allergies,
    dietaryRestrictions: diets,
    healthGoal: goal,
    dailyCalorieTarget: calorieTarget,
    mealsPerDay: mealsPerDay,
    walletBalance: wallet,
    caloriesConsumedToday: caloriesToday,
    proteinConsumedToday: proteinToday,
    carbsConsumedToday: carbsToday,
    fatConsumedToday: fatToday,
    recentMenuItemNames: recentNames,
    recentCuisines: recentCuisines,
    eligibleItems: items,
    recommendationCount: count,
  );
}

class RecordingOpenAi {
  final List<Map<String, Object?>> bodies = [];
  late final OpenAiClient client;

  RecordingOpenAi(String Function(Map<String, Object?> body) respond) {
    final mock = MockClient((req) async {
      final body = json.decode(req.body) as Map<String, Object?>;
      bodies.add(body);
      final content = respond(body);
      return http.Response(
        json.encode({
          'choices': [
            {
              'message': {'content': content},
            }
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    client = OpenAiClient(
      apiKey: 'test-key',
      baseUrl: 'https://stub.invalid',
      client: mock,
    );
  }

  Object? get lastSeed => bodies.isEmpty ? null : bodies.last['seed'];

  Map<String, Object?> get lastUserPayload {
    final messages =
        (bodies.last['messages'] as List).cast<Map<String, Object?>>();
    return json.decode(messages[1]['content'] as String)
        as Map<String, Object?>;
  }
}

String echoAllEligible(Map<String, Object?> body) {
  final messages = (body['messages'] as List).cast<Map<String, Object?>>();
  final payload =
      json.decode(messages[1]['content'] as String) as Map<String, Object?>;
  final items =
      (payload['eligible_items'] as List).cast<Map<String, Object?>>();
  return json.encode({
    'recommendations': [
      for (final item in items)
        {
          'menu_item_id': item['menu_item_id'],
          'restaurant_id': item['restaurant_id'],
          'reason': 'Good fit for today',
        }
    ],
  });
}

String modelContent(List<Map<String, Object?>> recommendations) =>
    json.encode({'recommendations': recommendations});

Map<String, Object?> rec(
  int menuItemId, {
  int? restaurantId,
  String reason = 'Fits your goal and budget today',
}) =>
    {
      'menu_item_id': menuItemId,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      'reason': reason,
    };
