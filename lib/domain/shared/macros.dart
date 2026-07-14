import 'failures.dart';

class Macros {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const Macros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  static const Macros zero = Macros(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    sugar: 0,
  );

  factory Macros.checked({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required double sugar,
  }) {
    final values = [calories, protein, carbs, fat, fiber, sugar];
    if (values.any((value) => value < 0)) {
      throw const ValidationFailure('Nutrient values must be 0 or greater');
    }
    return Macros(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
    );
  }

  Macros operator +(Macros other) => Macros(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
        fiber: fiber + other.fiber,
        sugar: sugar + other.sugar,
      );

  Macros scale(double factor) => Macros(
        calories: calories * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fat: fat * factor,
        fiber: fiber * factor,
        sugar: sugar * factor,
      );

  @override
  bool operator ==(Object other) =>
      other is Macros &&
      other.calories == calories &&
      other.protein == protein &&
      other.carbs == carbs &&
      other.fat == fat &&
      other.fiber == fiber &&
      other.sugar == sugar;

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat, fiber, sugar);
}
