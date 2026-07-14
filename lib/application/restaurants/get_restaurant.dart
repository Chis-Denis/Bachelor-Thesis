import '../../domain/restaurants/restaurant_repository.dart';
import 'restaurant_dto.dart';

class GetRestaurant {
  final RestaurantRepository _repository;

  const GetRestaurant(this._repository);

  Future<RestaurantDto?> call(int id) async {
    final restaurant = await _repository.findById(id);
    return restaurant == null ? null : RestaurantDto.fromDomain(restaurant);
  }
}
