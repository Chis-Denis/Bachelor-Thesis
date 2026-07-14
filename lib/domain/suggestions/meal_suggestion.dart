class MealSuggestion {
  final int menuItemId;
  final int restaurantId;
  final String restaurantName;
  final String itemName;
  final String category;
  final double price;
  final double calories;
  final String reason;

  const MealSuggestion({
    required this.menuItemId,
    required this.restaurantId,
    required this.restaurantName,
    required this.itemName,
    required this.category,
    required this.price,
    required this.calories,
    required this.reason,
  });
}
