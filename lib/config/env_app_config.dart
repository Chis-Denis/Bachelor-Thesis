import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/constants/openai_constants.dart';
import 'app_config.dart';

class EnvAppConfig implements AppConfig {
  const EnvAppConfig();

  static const String _usdaApiKeyEnv = 'USDA_API_KEY';
  static const String _usdaDemoKey = 'DEMO_KEY';
  static const String _usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';

  static const String _openAiApiKeyEnv = 'OPENAI_API_KEY';
  static const String _openAiBaseUrlEnv = 'OPENAI_BASE_URL';

  @override
  String get usdaApiKey {
    final value = dotenv.maybeGet(_usdaApiKeyEnv);
    if (value == null || value.isEmpty) return _usdaDemoKey;
    return value;
  }

  @override
  String get usdaBaseUrl => _usdaBaseUrl;

  @override
  String get openAiApiKey => dotenv.maybeGet(_openAiApiKeyEnv) ?? '';

  @override
  String get openAiBaseUrl {
    final value = dotenv.maybeGet(_openAiBaseUrlEnv);
    if (value == null || value.isEmpty) return OpenAiConstants.baseUrl;
    return value;
  }
}
