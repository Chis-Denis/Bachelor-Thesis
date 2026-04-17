import 'meal_type.dart';

class Meal {
  final int id;
  final String name;
  final MealType type;
  final double quantity;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final DateTime date;
  final String? notes;

  const Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.date,
    this.notes,
  });

  Meal copyWith({
    String? name,
    MealType? type,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    DateTime? date,
    String? notes,
  }) {
    return Meal(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
