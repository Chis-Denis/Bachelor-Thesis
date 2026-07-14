import '../../domain/ordering/order.dart';
import '../shared/macros_dto.dart';

class OrderLineDto {
  final String name;
  final String description;
  final double unitPrice;
  final double quantity;
  final double lineTotal;
  final MacrosDto macros;

  const OrderLineDto({
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.macros,
  });

  factory OrderLineDto.fromDomain(OrderLine line) => OrderLineDto(
        name: line.name,
        description: line.description,
        unitPrice: line.price.amount,
        quantity: line.quantity,
        lineTotal: line.lineTotal.amount,
        macros: MacrosDto.fromDomain(line.scaledMacros),
      );
}

class OrderDto {
  final int id;
  final int? restaurantId;
  final String restaurantName;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final List<OrderLineDto> lines;
  final MacrosDto totalMacros;
  final int itemCount;

  const OrderDto({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    required this.lines,
    required this.totalMacros,
    required this.itemCount,
  });

  factory OrderDto.fromDomain(Order order) => OrderDto(
        id: order.id,
        restaurantId: order.restaurantId,
        restaurantName: order.restaurantName,
        subtotal: order.subtotal.amount,
        deliveryFee: order.deliveryFee.amount,
        total: order.total.amount,
        createdAt: order.createdAt,
        lines: order.lines.map(OrderLineDto.fromDomain).toList(growable: false),
        totalMacros: MacrosDto.fromDomain(order.totalMacros),
        itemCount: order.itemCount,
      );
}
