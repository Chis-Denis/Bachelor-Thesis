import '../../../application/foods/food_data_type_view.dart';
import '../../../application/foods/food_source_view.dart';

class FoodLabels {
  FoodLabels._();

  static String source(FoodSourceView source) {
    switch (source) {
      case FoodSourceView.local:
        return 'Your foods';
      case FoodSourceView.usda:
        return 'USDA FoodData Central';
    }
  }

  static String badge(FoodDataTypeView type) {
    switch (type) {
      case FoodDataTypeView.foundation:
        return 'Raw';
      case FoodDataTypeView.srLegacy:
        return 'Generic';
      case FoodDataTypeView.survey:
        return 'Generic';
      case FoodDataTypeView.branded:
        return 'Branded';
      case FoodDataTypeView.custom:
        return 'Yours';
      case FoodDataTypeView.unknown:
        return 'USDA';
    }
  }
}
