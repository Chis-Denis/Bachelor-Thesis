import 'food_data_type.dart';
import 'food_source.dart';

class Food {
  final int? id;
  final int? fdcId;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double servingSize;
  final String servingUnit;
  final FoodSource source;
  final FoodDataType dataType;

  const Food({
    this.id,
    this.fdcId,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.servingSize,
    required this.servingUnit,
    required this.source,
    this.dataType = FoodDataType.unknown,
  });
}
