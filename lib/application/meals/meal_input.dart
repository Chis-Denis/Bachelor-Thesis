import '../shared/macros_dto.dart';
import 'meal_type_view.dart';

class MealInput {
  final String name;
  final MealTypeView type;
  final double quantity;
  final String unit;
  final MacrosDto macros;
  final DateTime? date;
  final String? notes;

  const MealInput({
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.macros,
    this.date,
    this.notes,
  });
}
