class EligibleMenuItem {
  final int menuItemId;
  final int restaurantId;
  final String restaurantName;
  final String cuisine;
  final String name;
  final String category;
  final String description;
  final double price;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const EligibleMenuItem({
    required this.menuItemId,
    required this.restaurantId,
    required this.restaurantName,
    required this.cuisine,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  String get searchableText => '$name $description';
}
