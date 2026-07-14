import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/constants/openai_constants.dart';
import '../../domain/shared/failures.dart';

class OpenAiClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  OpenAiClient({
    required this.apiKey,
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, Object?>> createChatCompletion(
    Map<String, Object?> body,
  ) async {
    if (apiKey.isEmpty) {
      throw const ConfigurationFailure(
        'OpenAI API key is not configured. Add OPENAI_API_KEY to your .env.',
      );
    }

    final uri = Uri.parse('$baseUrl${OpenAiConstants.chatCompletionsPath}');
    final payload = json.encode(body);

    for (var attempt = 1; attempt <= OpenAiConstants.maxAttempts; attempt++) {
      final http.Response response;
      try {
        response = await _client
            .post(
              uri,
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: payload,
            )
            .timeout(OpenAiConstants.requestTimeout);
      } on Exception catch (error) {
        throw SuggestionFailure('Could not reach OpenAI: $error');
      }

      final isLastAttempt = attempt == OpenAiConstants.maxAttempts;
      if (response.statusCode == 429 && !isLastAttempt) {
        await Future<void>.delayed(OpenAiConstants.retryBackoff);
        continue;
      }
      return _decode(response);
    }

    throw const SuggestionFailure(
      'OpenAI rate limit reached. Try again shortly.',
    );
  }

  Map<String, Object?> _decode(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<String, Object?>;
      case 401:
      case 403:
        throw const SuggestionFailure('OpenAI rejected the API key.');
      case 429:
        throw const SuggestionFailure(
          'OpenAI rate limit reached. Try again shortly.',
        );
      default:
        if (response.statusCode >= 500) {
          throw SuggestionFailure(
            'OpenAI is unavailable (${response.statusCode}).',
          );
        }
        throw SuggestionFailure(
          'OpenAI request failed (${response.statusCode}).',
        );
    }
  }

  void dispose() => _client.close();
}
