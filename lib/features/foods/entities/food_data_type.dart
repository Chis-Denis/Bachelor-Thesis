enum FoodDataType {
  foundation,
  srLegacy,
  survey,
  branded,
  custom,
  unknown;

  String get badgeLabel {
    switch (this) {
      case FoodDataType.foundation:
        return 'Raw';
      case FoodDataType.srLegacy:
        return 'Generic';
      case FoodDataType.survey:
        return 'Generic';
      case FoodDataType.branded:
        return 'Branded';
      case FoodDataType.custom:
        return 'Yours';
      case FoodDataType.unknown:
        return 'USDA';
    }
  }

  int get sortOrder {
    switch (this) {
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
      case FoodDataType.custom:
        return 0;
    }
  }

  static FoodDataType fromUsda(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'foundation':
        return FoodDataType.foundation;
      case 'sr legacy':
        return FoodDataType.srLegacy;
      case 'survey (fndds)':
        return FoodDataType.survey;
      case 'branded':
        return FoodDataType.branded;
      default:
        return FoodDataType.unknown;
    }
  }
}
