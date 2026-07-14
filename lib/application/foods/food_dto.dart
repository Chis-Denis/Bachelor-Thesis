import '../../domain/foods/food.dart';
import '../shared/macros_dto.dart';
import 'food_data_type_view.dart';
import 'food_source_view.dart';

class FoodDto {
  final String name;
  final MacrosDto macros;
  final double servingSize;
  final String servingUnit;
  final FoodSourceView source;
  final FoodDataTypeView dataType;

  const FoodDto({
    required this.name,
    required this.macros,
    required this.servingSize,
    required this.servingUnit,
    required this.source,
    required this.dataType,
  });

  factory FoodDto.fromDomain(Food food) => FoodDto(
        name: food.name,
        macros: MacrosDto.fromDomain(food.macros),
        servingSize: food.servingSize,
        servingUnit: food.servingUnit,
        source: FoodSourceView.fromDomain(food.source),
        dataType: FoodDataTypeView.fromDomain(food.dataType),
      );
}
