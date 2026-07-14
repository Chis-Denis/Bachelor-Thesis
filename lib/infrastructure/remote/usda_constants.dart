class UsdaConstants {
  UsdaConstants._();

  static const int pageSize = 20;
  static const int maxAttempts = 2;
  static const Duration retryDelay = Duration(milliseconds: 400);
  static const Duration requestTimeout = Duration(seconds: 10);

  static const List<String> dataTypes = [
    'Foundation',
    'SR Legacy',
    'Survey (FNDDS)',
    'Branded',
  ];

  static const int nutrientEnergyKcal = 1008;
  static const int nutrientProtein = 1003;
  static const int nutrientCarbs = 1005;
  static const int nutrientFat = 1004;
  static const int nutrientFiber = 1079;
  static const int nutrientSugar = 2000;

  static const double defaultServingSize = 100;
  static const String defaultServingUnit = 'g';
}
