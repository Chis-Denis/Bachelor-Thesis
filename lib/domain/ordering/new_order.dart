import '../shared/macros.dart';
import '../shared/money.dart';

class NewOrderLine {
  final int? menuItemId;
  final String name;
  final String description;
  final Money price;
  final double quantity;
  final Macros macros;

  const NewOrderLine({
    this.menuItemId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.macros,
  });
}

class NewOrder {
  final int? restaurantId;
  final String restaurantName;
  final Money subtotal;
  final Money deliveryFee;
  final Money total;
  final DateTime createdAt;
  final List<NewOrderLine> lines;

  const NewOrder({
    required this.restaurantId,
    required this.restaurantName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.lines,
  });
}
