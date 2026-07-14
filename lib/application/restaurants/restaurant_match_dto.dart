import '../../domain/restaurants/restaurant_match.dart';
import 'menu_item_dto.dart';
import 'restaurant_dto.dart';

class RestaurantMatchDto {
  final RestaurantDto restaurant;
  final List<MenuItemDto> matchedItems;

  const RestaurantMatchDto({
    required this.restaurant,
    required this.matchedItems,
  });

  factory RestaurantMatchDto.fromDomain(RestaurantMatch match) =>
      RestaurantMatchDto(
        restaurant: RestaurantDto.fromDomain(match.restaurant),
        matchedItems: match.matchedItems
            .map(MenuItemDto.fromDomain)
            .toList(growable: false),
      );
}
