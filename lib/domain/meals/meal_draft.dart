import '../shared/failures.dart';
import '../shared/macros.dart';
import '../shared/quantity.dart';
import 'meal_type.dart';

class MealDraft {
  final String name;
  final MealType type;
  final Quantity quantity;
  final String unit;
  final Macros macros;
  final DateTime date;
  final String? notes;

  const MealDraft._({
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.macros,
    required this.date,
    this.notes,
  });

  factory MealDraft({
    required String name,
    required MealType type,
    required Quantity quantity,
    required String unit,
    required Macros macros,
    required DateTime date,
    String? notes,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationFailure('Meal name is required');
    }
    final trimmedUnit = unit.trim();
    if (trimmedUnit.isEmpty) {
      throw const ValidationFailure('Unit is required');
    }
    return MealDraft._(
      name: trimmedName,
      type: type,
      quantity: quantity,
      unit: trimmedUnit,
      macros: macros,
      date: date,
      notes: notes,
    );
  }
}
