import '../../domain/meals/meal_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'meal_dto.dart';

class GetMeal {
  final MealRepository _repository;
  final SessionStore _session;

  const GetMeal(this._repository, this._session);

  Future<OperationResult<MealDto?>> call(int mealId) async {
    try {
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();
      final meal = await _repository.findById(mealId: mealId, userId: userId);
      return OperationResult.ok(meal == null ? null : MealDto.fromDomain(meal));
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load meal');
    }
  }
}
