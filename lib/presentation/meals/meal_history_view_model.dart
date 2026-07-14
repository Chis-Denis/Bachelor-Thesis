import '../../application/meals/delete_meal.dart';
import '../../application/meals/load_meals.dart';
import '../../application/meals/meal_dto.dart';
import '../../application/meals/meals_store.dart';
import '../common/formatters/date_format.dart';
import '../common/view_model.dart';

class MealHistoryViewModel extends ViewModel {
  final LoadMeals _loadMeals;
  final DeleteMeal _deleteMeal;
  final MealsStore _store;

  String? errorMessage;
  List<MealDto> _meals = const [];

  MealHistoryViewModel(this._loadMeals, this._deleteMeal, this._store) {
    _meals = _store.current;
    bind(_store.meals.changes, (meals) {
      _meals = meals;
      notify();
    });
  }

  List<MealDto> get pastMeals {
    final now = DateTime.now();
    return _meals
        .where((meal) => !isSameDay(meal.date, now))
        .toList(growable: false);
  }

  Future<void> load() async {
    final result = await _loadMeals();
    if (!result.isSuccess) {
      errorMessage = result.error;
      notify();
    }
  }

  Future<void> delete(int mealId) async {
    final result = await _deleteMeal(mealId);
    if (!result.isSuccess) {
      errorMessage = result.error;
      notify();
    }
  }

  void clearError() => errorMessage = null;
}
