import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/foods/food.dart';
import '../../domain/foods/remote_food_source.dart';
import '../../domain/shared/failures.dart';
import 'usda_constants.dart';
import 'usda_food_mapper.dart';

class UsdaClient implements RemoteFoodSource {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;
  final UsdaFoodMapper _mapper;

  UsdaClient({
    required this.apiKey,
    required this.baseUrl,
    http.Client? client,
    UsdaFoodMapper mapper = const UsdaFoodMapper(),
  })  : _client = client ?? http.Client(),
        _mapper = mapper;

  @override
  Future<List<Food>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse('$baseUrl/foods/search').replace(queryParameters: {
      'api_key': apiKey,
      'query': trimmed,
      'pageSize': UsdaConstants.pageSize.toString(),
      'dataType': UsdaConstants.dataTypes,
    });

    final response = await _fetch(uri);
    final body = json.decode(response.body) as Map<String, Object?>;
    final foods = (body['foods'] as List?) ?? const [];
    return foods
        .whereType<Map<String, Object?>>()
        .map(_mapper.map)
        .toList(growable: false);
  }

  Future<http.Response> _fetch(Uri uri) async {
    Object? lastError;
    for (var attempt = 1; attempt <= UsdaConstants.maxAttempts; attempt++) {
      try {
        final response =
            await _client.get(uri).timeout(UsdaConstants.requestTimeout);
        if (response.statusCode == 200) return response;
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const RemoteLookupFailure('USDA API key is invalid or missing');
        }
        if (response.statusCode == 429) {
          throw const RemoteLookupFailure(
            'USDA rate limit reached. Try again later.',
          );
        }
        if (attempt < UsdaConstants.maxAttempts &&
            _isTransient(response.statusCode)) {
          await Future.delayed(UsdaConstants.retryDelay);
          continue;
        }
        throw RemoteLookupFailure('USDA returned ${response.statusCode}');
      } on RemoteLookupFailure {
        rethrow;
      } catch (error) {
        lastError = error;
        if (attempt < UsdaConstants.maxAttempts) {
          await Future.delayed(UsdaConstants.retryDelay);
          continue;
        }
      }
    }
    throw RemoteLookupFailure('Could not reach USDA: $lastError');
  }

  bool _isTransient(int code) =>
      code == 400 || code == 408 || code == 502 || code == 503 || code == 504;

  void dispose() => _client.close();
}
