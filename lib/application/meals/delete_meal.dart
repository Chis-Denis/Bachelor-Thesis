import '../../domain/meals/meal_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'load_meals.dart';

class DeleteMeal {
  final MealRepository _repository;
  final SessionStore _session;
  final LoadMeals _loadMeals;

  const DeleteMeal(this._repository, this._session, this._loadMeals);

  Future<OperationResult<void>> call(int mealId) async {
    try {
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();
      await _repository.remove(mealId: mealId, userId: userId);
      await _loadMeals();
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not delete meal');
    }
  }
}
