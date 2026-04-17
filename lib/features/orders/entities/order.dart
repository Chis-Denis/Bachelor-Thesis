class OrderLineItem {
  final int? id;
  final int? menuItemId;
  final String name;
  final String description;
  final double price;
  final double quantity;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  const OrderLineItem({
    this.id,
    this.menuItemId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  double get lineTotal => price * quantity;
}

class Order {
  final int id;
  final int userId;
  final int? restaurantId;
  final String restaurantName;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final List<OrderLineItem> items;

  const Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  double get totalCalories =>
      items.fold(0, (sum, i) => sum + i.calories * i.quantity);
  double get totalProtein =>
      items.fold(0, (sum, i) => sum + i.protein * i.quantity);
  double get totalCarbs =>
      items.fold(0, (sum, i) => sum + i.carbs * i.quantity);
  double get totalFat =>
      items.fold(0, (sum, i) => sum + i.fat * i.quantity);
  double get totalFiber =>
      items.fold(0, (sum, i) => sum + i.fiber * i.quantity);
  double get totalSugar =>
      items.fold(0, (sum, i) => sum + i.sugar * i.quantity);

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity.round());
}
