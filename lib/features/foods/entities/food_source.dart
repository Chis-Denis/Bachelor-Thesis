enum FoodSource {
  local,
  usda;

  String get label {
    switch (this) {
      case FoodSource.local:
        return 'Your foods';
      case FoodSource.usda:
        return 'USDA FoodData Central';
    }
  }
}
