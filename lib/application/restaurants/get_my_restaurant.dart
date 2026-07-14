import '../../domain/restaurants/restaurant_repository.dart';
import '../auth/session_store.dart';
import 'restaurant_dto.dart';

class GetMyRestaurant {
  final RestaurantRepository _repository;
  final SessionStore _session;

  const GetMyRestaurant(this._repository, this._session);

  Future<RestaurantDto?> call() async {
    final ownerId = _session.userId;
    if (ownerId == null) return null;
    final restaurant = await _repository.findByOwner(ownerId);
    return restaurant == null ? null : RestaurantDto.fromDomain(restaurant);
  }
}
