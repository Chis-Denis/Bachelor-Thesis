import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../exceptions/app_exception.dart';
import '../entities/food.dart';
import '../entities/food_data_type.dart';
import '../entities/food_source.dart';

class UsdaNutritionService {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  UsdaNutritionService({
    required this.apiKey,
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const int _nutrientEnergyKcal = 1008;
  static const int _nutrientProtein = 1003;
  static const int _nutrientCarbs = 1005;
  static const int _nutrientFat = 1004;
  static const int _nutrientFiber = 1079;
  static const int _nutrientSugar = 2000;

  static const double _maxKcalPerGram = 9.5;
  static const double _macroKcalTolerance = 25.0;
  static const double _macroEpsilon = 0.1;

  Future<List<Food>> search(String query, {int pageSize = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse('$baseUrl/foods/search').replace(queryParameters: {
      'api_key': apiKey,
      'query': trimmed,
      'pageSize': pageSize.toString(),
      'dataType': const ['Foundation', 'SR Legacy', 'Survey (FNDDS)', 'Branded'],
    });

    final response = await _fetchWithRetry(uri);

    final body = json.decode(response.body) as Map<String, Object?>;
    final foods = (body['foods'] as List?) ?? const [];
    return foods
        .whereType<Map<String, Object?>>()
        .map(_mapFood)
        .where(_isPlausible)
        .toList(growable: false);
  }

  Future<http.Response> _fetchWithRetry(Uri uri) async {
    const maxAttempts = 2;
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response =
            await _client.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) return response;

        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const AppException('USDA API key is invalid or missing');
        }
        if (response.statusCode == 429) {
          throw const AppException(
            'USDA rate limit reached. Try again later.',
          );
        }

        if (attempt < maxAttempts && _isTransientStatus(response.statusCode)) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }
        throw AppException('USDA returned ${response.statusCode}');
      } on AppException {
        rethrow;
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }
      }
    }
    throw AppException('Could not reach USDA: $lastError');
  }

  bool _isTransientStatus(int code) {
    return code == 400 || code == 408 || code == 502 || code == 503 ||
        code == 504;
  }

  Food _mapFood(Map<String, Object?> json) {
    final name = (json['description'] as String?)?.trim() ?? 'Unknown food';
    final fdcId = (json['fdcId'] as num?)?.toInt();
    final nutrients = _mapNutrients(json['foodNutrients']);
    final servingSize = (json['servingSize'] as num?)?.toDouble() ?? 100;
    final servingUnit =
        (json['servingSizeUnit'] as String?)?.trim().toLowerCase() ?? 'g';
    final dataType = FoodDataType.fromUsda(json['dataType'] as String?);

    return Food(
      fdcId: fdcId,
      name: name,
      calories: nutrients[_nutrientEnergyKcal] ?? 0,
      protein: nutrients[_nutrientProtein] ?? 0,
      carbs: nutrients[_nutrientCarbs] ?? 0,
      fat: nutrients[_nutrientFat] ?? 0,
      fiber: nutrients[_nutrientFiber] ?? 0,
      sugar: nutrients[_nutrientSugar] ?? 0,
      servingSize: servingSize,
      servingUnit: servingUnit,
      source: FoodSource.usda,
      dataType: dataType,
    );
  }

  bool _isPlausible(Food food) {
    if (food.servingSize <= 0) return false;

    final hasMacros = food.protein > _macroEpsilon ||
        food.carbs > _macroEpsilon ||
        food.fat > _macroEpsilon;
    if (food.calories <= _macroEpsilon && hasMacros) return false;

    final estimatedKcal =
        food.protein * 4 + food.carbs * 4 + food.fat * 9;
    if ((food.calories - estimatedKcal).abs() > _macroKcalTolerance) {
      return false;
    }

    final unit = food.servingUnit.toLowerCase();
    if (unit == 'g' || unit == 'ml') {
      final density = food.calories / food.servingSize;
      if (density > _maxKcalPerGram) return false;
    }

    return true;
  }

  Map<int, double> _mapNutrients(Object? raw) {
    if (raw is! List) return const {};
    final out = <int, double>{};
    for (final item in raw) {
      if (item is! Map<String, Object?>) continue;
      final id = (item['nutrientId'] as num?)?.toInt();
      final value = (item['value'] as num?)?.toDouble();
      if (id != null && value != null) out[id] = value;
    }
    return out;
  }

  void dispose() => _client.close();
}
