import '../../domain/suggestions/meal_suggestion.dart';

class MealSuggestionDto {
  final int menuItemId;
  final int restaurantId;
  final String restaurantName;
  final String itemName;
  final String category;
  final double price;
  final double calories;
  final String reason;

  const MealSuggestionDto({
    required this.menuItemId,
    required this.restaurantId,
    required this.restaurantName,
    required this.itemName,
    required this.category,
    required this.price,
    required this.calories,
    required this.reason,
  });

  factory MealSuggestionDto.fromDomain(MealSuggestion suggestion) =>
      MealSuggestionDto(
        menuItemId: suggestion.menuItemId,
        restaurantId: suggestion.restaurantId,
        restaurantName: suggestion.restaurantName,
        itemName: suggestion.itemName,
        category: suggestion.category,
        price: suggestion.price,
        calories: suggestion.calories,
        reason: suggestion.reason,
      );
}
