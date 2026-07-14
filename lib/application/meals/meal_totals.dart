import '../shared/macros_dto.dart';
import 'meal_dto.dart';

class MealTotals {
  MealTotals._();

  static MacrosDto forDay(List<MealDto> meals, DateTime day) {
    var totals = MacrosDto.zero;
    for (final meal in meals) {
      if (_sameDay(meal.date, day)) {
        totals = totals + meal.macros;
      }
    }
    return totals;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
