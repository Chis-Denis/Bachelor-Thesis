import '../shared/macros.dart';
import '../shared/money.dart';

class OrderLine {
  final int? id;
  final int? menuItemId;
  final String name;
  final String description;
  final Money price;
  final double quantity;
  final Macros macros;

  const OrderLine({
    this.id,
    this.menuItemId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.macros,
  });

  Money get lineTotal => price.scale(quantity);

  Macros get scaledMacros => macros.scale(quantity);
}

class Order {
  final int id;
  final int userId;
  final int? restaurantId;
  final String restaurantName;
  final Money subtotal;
  final Money deliveryFee;
  final Money total;
  final DateTime createdAt;
  final List<OrderLine> lines;

  const Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.lines,
  });

  Macros get totalMacros =>
      lines.fold(Macros.zero, (sum, line) => sum + line.scaledMacros);

  int get itemCount =>
      lines.fold(0, (sum, line) => sum + line.quantity.round());
}
