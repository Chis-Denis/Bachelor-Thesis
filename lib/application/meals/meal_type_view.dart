import '../../domain/meals/meal_type.dart';

enum MealTypeView {
  breakfast,
  lunch,
  dinner,
  snack;

  MealType toDomain() {
    switch (this) {
      case MealTypeView.breakfast:
        return MealType.breakfast;
      case MealTypeView.lunch:
        return MealType.lunch;
      case MealTypeView.dinner:
        return MealType.dinner;
      case MealTypeView.snack:
        return MealType.snack;
    }
  }

  static MealTypeView fromDomain(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return MealTypeView.breakfast;
      case MealType.lunch:
        return MealTypeView.lunch;
      case MealType.dinner:
        return MealTypeView.dinner;
      case MealType.snack:
        return MealTypeView.snack;
    }
  }

  static MealTypeView defaultForHour(int hour) =>
      fromDomain(MealType.defaultForHour(hour));
}
