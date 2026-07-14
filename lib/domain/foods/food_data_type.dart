enum FoodDataType {
  foundation,
  srLegacy,
  survey,
  branded,
  custom,
  unknown;

  int get sortOrder {
    switch (this) {
      case FoodDataType.custom:
        return 0;
      case FoodDataType.foundation:
        return 0;
      case FoodDataType.srLegacy:
        return 1;
      case FoodDataType.survey:
        return 2;
      case FoodDataType.branded:
        return 3;
      case FoodDataType.unknown:
        return 4;
    }
  }
}
