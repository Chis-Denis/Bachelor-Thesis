import '../../domain/ordering/cart.dart';
import '../shared/macros_dto.dart';

class CartLineDto {
  final int menuItemId;
  final String name;
  final String description;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final MacrosDto macros;

  const CartLineDto({
    required this.menuItemId,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.macros,
  });

  factory CartLineDto.fromDomain(CartLine line) => CartLineDto(
        menuItemId: line.item.id,
        name: line.item.name,
        description: line.item.description,
        unitPrice: line.item.price.amount,
        quantity: line.quantity,
        lineTotal: line.lineTotal.amount,
        macros: MacrosDto.fromDomain(line.item.macros),
      );
}
