import '../../domain/foods/food.dart';
import '../../domain/foods/food_data_type.dart';
import '../../domain/foods/food_repository.dart';
import '../../domain/foods/food_source.dart';
import '../../domain/meals/meal.dart';
import '../../domain/meals/meal_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'load_meals.dart';
import 'meal_draft_factory.dart';
import 'meal_input.dart';

class UpdateMeal {
  final MealRepository _repository;
  final FoodRepository _foods;
  final SessionStore _session;
  final LoadMeals _loadMeals;

  const UpdateMeal(
    this._repository,
    this._foods,
    this._session,
    this._loadMeals,
  );

  Future<OperationResult<void>> call(int mealId, MealInput input) async {
    try {
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();
      final draft = MealDraftFactory.fromInput(input);
      final meal = Meal(
        id: mealId,
        name: draft.name,
        type: draft.type,
        quantity: draft.quantity.value,
        unit: draft.unit,
        macros: draft.macros,
        date: draft.date,
        notes: draft.notes,
      );
      await _repository.update(userId: userId, meal: meal);
      await _foods.upsert(
        userId: userId,
        food: Food(
          name: draft.name,
          macros: draft.macros,
          servingSize: draft.quantity.value,
          servingUnit: draft.unit,
          source: FoodSource.local,
          dataType: FoodDataType.custom,
        ),
      );
      await _loadMeals();
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not update meal');
    }
  }
}
