import '../../domain/meals/meal.dart';
import '../shared/macros_dto.dart';
import 'meal_type_view.dart';

class MealDto {
  final int id;
  final String name;
  final MealTypeView type;
  final double quantity;
  final String unit;
  final MacrosDto macros;
  final DateTime date;
  final String? notes;

  const MealDto({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.macros,
    required this.date,
    this.notes,
  });

  factory MealDto.fromDomain(Meal meal) => MealDto(
        id: meal.id,
        name: meal.name,
        type: MealTypeView.fromDomain(meal.type),
        quantity: meal.quantity,
        unit: meal.unit,
        macros: MacrosDto.fromDomain(meal.macros),
        date: meal.date,
        notes: meal.notes,
      );
}
