import '../../application/meals/delete_meal.dart';
import '../../application/meals/load_meals.dart';
import '../../application/meals/meal_dto.dart';
import '../../application/meals/meal_totals.dart';
import '../../application/meals/meal_type_view.dart';
import '../../application/meals/meals_store.dart';
import '../../application/shared/macros_dto.dart';
import '../common/formatters/date_format.dart';
import '../common/view_model.dart';

class HomeViewModel extends ViewModel {
  final LoadMeals _loadMeals;
  final DeleteMeal _deleteMeal;
  final MealsStore _store;

  static const int _morningSnackBeforeHour = 11;
  static const int _afternoonSnackBeforeHour = 16;

  bool isLoading = false;
  String? errorMessage;
  List<MealDto> _meals = const [];

  HomeViewModel(this._loadMeals, this._deleteMeal, this._store) {
    _meals = _store.current;
    bind(_store.meals.changes, (meals) {
      _meals = meals;
      notify();
    });
  }

  List<MealDto> get todaysMeals {
    final now = DateTime.now();
    final meals = _meals.where((meal) => isSameDay(meal.date, now)).toList();
    meals.sort((a, b) {
      final bySlot = _slot(a).compareTo(_slot(b));
      if (bySlot != 0) return bySlot;
      return a.date.compareTo(b.date);
    });
    return meals;
  }

  MacrosDto get todayTotals => MealTotals.forDay(_meals, DateTime.now());

  Future<void> load() async {
    isLoading = true;
    notify();
    final result = await _loadMeals();
    if (!result.isSuccess) errorMessage = result.error;
    isLoading = false;
    notify();
  }

  Future<void> delete(int mealId) async {
    final result = await _deleteMeal(mealId);
    if (!result.isSuccess) {
      errorMessage = result.error;
      notify();
    }
  }

  void clearError() => errorMessage = null;

  int _slot(MealDto meal) {
    switch (meal.type) {
      case MealTypeView.breakfast:
        return 0;
      case MealTypeView.snack:
        final hour = meal.date.hour;
        if (hour < _morningSnackBeforeHour) return 1;
        if (hour < _afternoonSnackBeforeHour) return 3;
        return 5;
      case MealTypeView.lunch:
        return 2;
      case MealTypeView.dinner:
        return 4;
    }
  }
}
