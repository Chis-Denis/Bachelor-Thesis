import '../../domain/restaurants/restaurant.dart';
import '../../domain/restaurants/restaurant_draft.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/money.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'restaurant_form_dto.dart';

class SaveMyRestaurant {
  final RestaurantRepository _repository;
  final SessionStore _session;

  const SaveMyRestaurant(this._repository, this._session);

  Future<OperationResult<int>> call(RestaurantFormDto form) async {
    try {
      final ownerId = _session.userId;
      if (ownerId == null) throw const NotAuthenticatedFailure();
      if (form.name.trim().isEmpty) {
        throw const ValidationFailure('Restaurant name is required');
      }
      if (form.cuisine.trim().isEmpty) {
        throw const ValidationFailure('Cuisine is required');
      }

      final draft = RestaurantDraft(
        name: form.name.trim(),
        cuisine: form.cuisine.trim(),
        deliveryFee: Money(form.deliveryFee),
        estimatedMinutes: form.estimatedMinutes,
      );

      final existing = await _repository.findByOwner(ownerId);
      if (existing == null) {
        final id = await _repository.createRestaurant(
          ownerUserId: ownerId,
          draft: draft,
        );
        return OperationResult.ok(id);
      }

      await _repository.updateRestaurant(Restaurant(
        id: existing.id,
        name: draft.name,
        cuisine: draft.cuisine,
        deliveryFee: draft.deliveryFee,
        rating: existing.rating,
        estimatedMinutes: draft.estimatedMinutes,
        ownerUserId: ownerId,
      ));
      return OperationResult.ok(existing.id);
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not save restaurant');
    }
  }
}
