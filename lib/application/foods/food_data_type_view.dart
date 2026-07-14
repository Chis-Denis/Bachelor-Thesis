import '../../domain/foods/food_data_type.dart';

enum FoodDataTypeView {
  foundation,
  srLegacy,
  survey,
  branded,
  custom,
  unknown;

  static FoodDataTypeView fromDomain(FoodDataType type) {
    switch (type) {
      case FoodDataType.foundation:
        return FoodDataTypeView.foundation;
      case FoodDataType.srLegacy:
        return FoodDataTypeView.srLegacy;
      case FoodDataType.survey:
        return FoodDataTypeView.survey;
      case FoodDataType.branded:
        return FoodDataTypeView.branded;
      case FoodDataType.custom:
        return FoodDataTypeView.custom;
      case FoodDataType.unknown:
        return FoodDataTypeView.unknown;
    }
  }
}
