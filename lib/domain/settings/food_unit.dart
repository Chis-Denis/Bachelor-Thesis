enum FoodUnit {
  grams,
  ounces;

  String get label => switch (this) {
        FoodUnit.grams => 'Metric (g)',
        FoodUnit.ounces => 'Imperial (oz)',
      };

  String get symbol => switch (this) {
        FoodUnit.grams => 'g',
        FoodUnit.ounces => 'oz',
      };
}
