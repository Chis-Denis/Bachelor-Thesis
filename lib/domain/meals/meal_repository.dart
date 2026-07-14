import 'meal.dart';
import 'meal_draft.dart';

abstract interface class MealRepository {
  Future<List<Meal>> findByUser(int userId);

  Future<Meal?> findById({required int mealId, required int userId});

  Future<Meal> add({required int userId, required MealDraft draft});

  Future<void> update({required int userId, required Meal meal});

  Future<void> remove({required int mealId, required int userId});
}
