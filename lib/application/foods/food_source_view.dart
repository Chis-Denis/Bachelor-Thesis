import '../../domain/foods/food_source.dart';

enum FoodSourceView {
  local,
  usda;

  static FoodSourceView fromDomain(FoodSource source) {
    switch (source) {
      case FoodSource.local:
        return FoodSourceView.local;
      case FoodSource.usda:
        return FoodSourceView.usda;
    }
  }
}
