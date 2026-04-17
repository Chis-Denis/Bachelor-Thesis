import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static String get usdaApiKey {
    final value = dotenv.maybeGet('USDA_API_KEY');
    if (value == null || value.isEmpty) return 'DEMO_KEY';
    return value;
  }

  static const String usdaBaseUrl = 'https://api.nal.usda.gov/fdc/v1';
}
