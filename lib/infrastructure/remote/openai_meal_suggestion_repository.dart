import 'dart:convert';

import '../../domain/constants/openai_constants.dart';
import '../../domain/constants/suggestion_constants.dart';
import '../../domain/shared/failures.dart';
import '../../domain/suggestions/eligible_menu_item.dart';
import '../../domain/suggestions/goal_guidance.dart';
import '../../domain/suggestions/meal_suggestion.dart';
import '../../domain/suggestions/meal_suggestion_repository.dart';
import '../../domain/suggestions/stable_hash.dart';
import '../../domain/suggestions/suggestion_request.dart';
import 'openai_client.dart';

class OpenAiMealSuggestionRepository implements MealSuggestionRepository {
  final OpenAiClient _client;

  const OpenAiMealSuggestionRepository(this._client);

  @override
  Future<List<MealSuggestion>> suggest(SuggestionRequest request) async {
    final response = await _client.createChatCompletion(_buildBody(request));
    final content = _extractContent(response);
    return _validate(content, request);
  }

  Map<String, Object?> _buildBody(SuggestionRequest request) => {
        'model': OpenAiConstants.model,
        'temperature': OpenAiConstants.temperature,
        'max_tokens': OpenAiConstants.maxTokens,
        'seed': _seed(request),
        'response_format': _responseFormat(),
        'messages': [
          {
            'role': 'system',
            'content': _systemPrompt(request.recommendationCount),
          },
          {
            'role': 'user',
            'content': json.encode(_userPayload(request)),
          },
        ],
      };

  int _seed(SuggestionRequest request) {
    final parts = <String>[
      request.userId.toString(),
      request.healthGoal?.name ?? '',
      request.caloriesConsumedToday.round().toString(),
      request.walletBalance.round().toString(),
      request.recommendationCount.toString(),
      for (final item in request.eligibleItems) item.menuItemId.toString(),
    ];
    return StableHash.fnv1a(parts.join('|'));
  }

  Map<String, Object?> _responseFormat() => {
        'type': 'json_schema',
        'json_schema': {
          'name': OpenAiConstants.schemaName,
          'strict': true,
          'schema': {
            'type': 'object',
            'properties': {
              'recommendations': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'properties': {
                    'menu_item_id': {'type': 'integer'},
                    'restaurant_id': {'type': 'integer'},
                    'reason': {'type': 'string'},
                  },
                  'required': ['menu_item_id', 'restaurant_id', 'reason'],
                  'additionalProperties': false,
                },
              },
            },
            'required': ['recommendations'],
            'additionalProperties': false,
          },
        },
      };

  String _systemPrompt(int count) =>
      'You are a personal nutrition assistant that selects meal recommendations '
      'from a pre-vetted list of eligible items.\n'
      'RULES (non-negotiable):\n'
      '1. Only return items whose menu_item_id exists in eligible_items.\n'
      '2. Return exactly $count items unless eligible_items has fewer.\n'
      '3. Prioritise items that best fit goal, goal_guidance, the remaining '
      'macro budget, and the recent history.\n'
      '4. reason must be one plain-English sentence of at most '
      '${SuggestionConstants.maxReasonLength} characters explaining why the item '
      'suits the user right now.\n'
      '5. Do not repeat the item name inside reason.\n'
      '6. Return items in ranked order, best fit first.';

  Map<String, Object?> _userPayload(SuggestionRequest request) {
    final payload = <String, Object?>{
      'recommendation_count': request.recommendationCount,
      'wallet_balance_lei': _round2(request.walletBalance),
      'calories_consumed_today': request.caloriesConsumedToday.round(),
      'protein_consumed_today_g': request.proteinConsumedToday.round(),
      'carbs_consumed_today_g': request.carbsConsumedToday.round(),
      'fat_consumed_today_g': request.fatConsumedToday.round(),
      'eligible_items':
          request.eligibleItems.map(_eligibleItemJson).toList(growable: false),
    };

    final goal = request.healthGoal;
    if (goal != null) {
      payload['goal'] = goal.name;
      final guidance = goalGuidance[goal];
      if (guidance != null) payload['goal_guidance'] = guidance;
    }

    final target = request.dailyCalorieTarget;
    if (target != null) {
      payload['daily_calorie_target'] = target;
      payload['remaining_calories'] = request.remainingCalories!.round();
    }

    if (request.recentMenuItemNames.isNotEmpty) {
      payload['recent_item_names'] = request.recentMenuItemNames;
    }
    if (request.recentCuisines.isNotEmpty) {
      payload['recent_cuisines_by_frequency'] = request.recentCuisines;
    }

    return payload;
  }

  Map<String, Object?> _eligibleItemJson(EligibleMenuItem item) => {
        'menu_item_id': item.menuItemId,
        'restaurant_id': item.restaurantId,
        'restaurant_name': item.restaurantName,
        'cuisine': item.cuisine,
        'name': item.name,
        'category': item.category,
        'price_lei': _round2(item.price),
        'calories': item.calories.round(),
        'protein_g': item.protein.round(),
        'carbs_g': item.carbs.round(),
        'fat_g': item.fat.round(),
        'fiber_g': item.fiber.round(),
      };

  String _extractContent(Map<String, Object?> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const SuggestionFailure('OpenAI returned no choices.');
    }
    final message = (choices.first as Map)['message'];
    final content = message is Map ? message['content'] : null;
    if (content is! String || content.isEmpty) {
      throw const SuggestionFailure('OpenAI returned an empty response.');
    }
    return content;
  }

  List<MealSuggestion> _validate(String content, SuggestionRequest request) {
    final decoded = json.decode(content);
    final recommendations =
        decoded is Map<String, Object?> ? decoded['recommendations'] : null;
    if (recommendations is! List) {
      throw const SuggestionFailure('Malformed suggestion response.');
    }

    final itemsById = <int, EligibleMenuItem>{
      for (final item in request.eligibleItems) item.menuItemId: item,
    };

    final suggestions = <MealSuggestion>[];
    final usedIds = <int>{};
    for (final raw in recommendations) {
      if (raw is! Map) continue;
      final menuItemId = _asInt(raw['menu_item_id']);
      if (menuItemId == null) continue;
      final item = itemsById[menuItemId];
      if (item == null) continue;

      final restaurantId = _asInt(raw['restaurant_id']);
      if (restaurantId != null && restaurantId != item.restaurantId) continue;
      if (!usedIds.add(menuItemId)) continue;

      final reason = _clampReason(raw['reason']);
      if (reason.isEmpty) continue;

      suggestions.add(MealSuggestion(
        menuItemId: item.menuItemId,
        restaurantId: item.restaurantId,
        restaurantName: item.restaurantName,
        itemName: item.name,
        category: item.category,
        price: item.price,
        calories: item.calories,
        reason: reason,
      ));
    }

    if (suggestions.isEmpty) {
      throw const SuggestionFailure('No valid items were returned.');
    }
    if (suggestions.length <= request.recommendationCount) return suggestions;
    return suggestions.sublist(0, request.recommendationCount);
  }

  String _clampReason(Object? value) {
    if (value is! String) return '';
    final trimmed = value.trim();
    if (trimmed.length <= SuggestionConstants.maxReasonLength) return trimmed;
    final window = trimmed.substring(0, SuggestionConstants.maxReasonLength);
    final lastSpace = window.lastIndexOf(' ');
    final boundary = lastSpace > 0 ? window.substring(0, lastSpace) : window;
    return boundary.trimRight();
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double _round2(double value) => (value * 100).round() / 100;
}
