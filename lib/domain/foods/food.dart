import '../shared/macros.dart';
import 'food_data_type.dart';
import 'food_source.dart';

class Food {
  final int? id;
  final int? fdcId;
  final String name;
  final Macros macros;
  final double servingSize;
  final String servingUnit;
  final FoodSource source;
  final FoodDataType dataType;

  const Food({
    this.id,
    this.fdcId,
    required this.name,
    required this.macros,
    required this.servingSize,
    required this.servingUnit,
    required this.source,
    this.dataType = FoodDataType.unknown,
  });
}
