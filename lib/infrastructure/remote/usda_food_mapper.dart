import '../../domain/foods/food.dart';
import '../../domain/foods/food_data_type.dart';
import '../../domain/foods/food_source.dart';
import '../../domain/shared/macros.dart';
import 'usda_constants.dart';

class UsdaFoodMapper {
  const UsdaFoodMapper();

  Food map(Map<String, Object?> json) {
    final description = (json['description'] as String?)?.trim();
    final nutrients = _nutrients(json['foodNutrients']);
    return Food(
      fdcId: (json['fdcId'] as num?)?.toInt(),
      name: description == null || description.isEmpty
          ? 'Unknown food'
          : description,
      macros: Macros(
        calories: nutrients[UsdaConstants.nutrientEnergyKcal] ?? 0,
        protein: nutrients[UsdaConstants.nutrientProtein] ?? 0,
        carbs: nutrients[UsdaConstants.nutrientCarbs] ?? 0,
        fat: nutrients[UsdaConstants.nutrientFat] ?? 0,
        fiber: nutrients[UsdaConstants.nutrientFiber] ?? 0,
        sugar: nutrients[UsdaConstants.nutrientSugar] ?? 0,
      ),
      servingSize: (json['servingSize'] as num?)?.toDouble() ??
          UsdaConstants.defaultServingSize,
      servingUnit: (json['servingSizeUnit'] as String?)?.trim().toLowerCase() ??
          UsdaConstants.defaultServingUnit,
      source: FoodSource.usda,
      dataType: _dataType(json['dataType'] as String?),
    );
  }

  Map<int, double> _nutrients(Object? raw) {
    if (raw is! List) return const {};
    final out = <int, double>{};
    for (final item in raw) {
      if (item is! Map<String, Object?>) continue;
      final id = (item['nutrientId'] as num?)?.toInt();
      final value = (item['value'] as num?)?.toDouble();
      if (id != null && value != null) out[id] = value;
    }
    return out;
  }

  FoodDataType _dataType(String? raw) {
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
