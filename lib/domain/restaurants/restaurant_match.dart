import 'menu_item.dart';
import 'restaurant.dart';

class RestaurantMatch {
  final Restaurant restaurant;
  final List<MenuItem> matchedItems;

  const RestaurantMatch({
    required this.restaurant,
    required this.matchedItems,
  });

  RestaurantMatch withItems(List<MenuItem> items) =>
      RestaurantMatch(restaurant: restaurant, matchedItems: items);
}
