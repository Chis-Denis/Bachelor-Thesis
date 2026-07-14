class OpenAiConstants {
  OpenAiConstants._();

  static const String model = 'gpt-4o-2024-08-06';

  static const String baseUrl = 'https://api.openai.com';
  static const String chatCompletionsPath = '/v1/chat/completions';

  static const int temperature = 0;
  static const int maxTokens = 512;

  static const Duration requestTimeout = Duration(seconds: 20);

  static const int maxAttempts = 2;
  static const Duration retryBackoff = Duration(seconds: 2);

  static const String schemaName = 'meal_recommendations';
}
