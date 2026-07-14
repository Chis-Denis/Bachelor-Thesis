import '../../domain/meals/meal_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'meal_dto.dart';
import 'meals_store.dart';

class LoadMeals {
  final MealRepository _repository;
  final SessionStore _session;
  final MealsStore _store;

  const LoadMeals(this._repository, this._session, this._store);

  Future<OperationResult<void>> call() async {
    try {
      final userId = _session.userId;
      if (userId == null) {
        _store.clear();
        return const OperationResult.ok();
      }
      final meals = await _repository.findByUser(userId);
      _store.set(meals.map(MealDto.fromDomain).toList(growable: false));
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load meals');
    }
  }
}
