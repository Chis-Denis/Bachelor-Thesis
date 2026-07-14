enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  static const int _breakfastStartHour = 5;
  static const int _lunchStartHour = 11;
  static const int _afternoonStartHour = 15;
  static const int _dinnerStartHour = 17;
  static const int _dinnerEndHour = 22;

  static MealType parse(String? value) {
    for (final type in MealType.values) {
      if (type.name == value) return type;
    }
    return MealType.snack;
  }

  static MealType defaultForHour(int hour) {
    if (hour >= _breakfastStartHour && hour < _lunchStartHour) {
      return MealType.breakfast;
    }
    if (hour >= _lunchStartHour && hour < _afternoonStartHour) {
      return MealType.lunch;
    }
    if (hour >= _dinnerStartHour && hour < _dinnerEndHour) {
      return MealType.dinner;
    }
    return MealType.snack;
  }
}
