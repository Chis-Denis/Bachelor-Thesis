import '../shared/macros.dart';
import 'meal_type.dart';

class Meal {
  final int id;
  final String name;
  final MealType type;
  final double quantity;
  final String unit;
  final Macros macros;
  final DateTime date;
  final String? notes;

  const Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.macros,
    required this.date,
    this.notes,
  });

  bool isOnDay(DateTime day) =>
      date.year == day.year && date.month == day.month && date.day == day.day;
}
