import '../../domain/restaurants/restaurant.dart';

class RestaurantDto {
  final int id;
  final String name;
  final String cuisine;
  final double deliveryFee;
  final double rating;
  final int estimatedMinutes;

  const RestaurantDto({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.deliveryFee,
    required this.rating,
    required this.estimatedMinutes,
  });

  factory RestaurantDto.fromDomain(Restaurant restaurant) => RestaurantDto(
        id: restaurant.id,
        name: restaurant.name,
        cuisine: restaurant.cuisine,
        deliveryFee: restaurant.deliveryFee.amount,
        rating: restaurant.rating,
        estimatedMinutes: restaurant.estimatedMinutes,
      );
}
