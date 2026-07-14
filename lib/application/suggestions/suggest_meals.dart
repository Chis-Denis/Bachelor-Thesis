import '../../domain/shared/failures.dart';
import '../../domain/suggestions/meal_suggestion_repository.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'meal_suggestion_dto.dart';
import 'suggestion_context_builder.dart';

class SuggestMeals {
  final SessionStore _session;
  final SuggestionContextBuilder _contextBuilder;
  final MealSuggestionRepository _repository;

  const SuggestMeals(this._session, this._contextBuilder, this._repository);

  Future<OperationResult<List<MealSuggestionDto>>> call() async {
    try {
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();

      final request = await _contextBuilder.build(userId);
      if (request.eligibleItems.isEmpty) {
        return const OperationResult.fail(
          'No menu items match your preferences and budget right now.',
        );
      }

      final suggestions = await _repository.suggest(request);
      if (suggestions.isEmpty) {
        return const OperationResult.fail('No suitable meals were found.');
      }

      return OperationResult.ok(
        suggestions.map(MealSuggestionDto.fromDomain).toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not generate suggestions.');
    }
  }
}
