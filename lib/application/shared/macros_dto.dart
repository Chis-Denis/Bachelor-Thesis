import '../../domain/shared/macros.dart';

class MacrosDto {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const MacrosDto({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  static const MacrosDto zero = MacrosDto(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    sugar: 0,
  );

  factory MacrosDto.fromDomain(Macros macros) => MacrosDto(
        calories: macros.calories,
        protein: macros.protein,
        carbs: macros.carbs,
        fat: macros.fat,
        fiber: macros.fiber,
        sugar: macros.sugar,
      );

  Macros toDomain() => Macros(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        sugar: sugar,
      );

  MacrosDto operator +(MacrosDto other) => MacrosDto(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
        fiber: fiber + other.fiber,
        sugar: sugar + other.sugar,
      );
}
