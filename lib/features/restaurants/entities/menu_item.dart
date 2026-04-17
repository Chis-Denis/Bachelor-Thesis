import 'restaurant.dart';

class MenuItem {
  final int id;
  final int restaurantId;
  final String name;
  final String description;
  final String category;
  final double price;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });
}

class RestaurantWithMatches {
  final Restaurant restaurant;
  final List<MenuItem> matchedItems;

  const RestaurantWithMatches({
    required this.restaurant,
    required this.matchedItems,
  });
}
