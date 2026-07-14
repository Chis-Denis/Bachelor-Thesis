import '../../domain/ordering/cart.dart';
import '../restaurants/restaurant_dto.dart';
import 'cart_line_dto.dart';

class CartDto {
  final RestaurantDto? restaurant;
  final List<CartLineDto> lines;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final int itemCount;
  final bool isEmpty;

  const CartDto({
    required this.restaurant,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.itemCount,
    required this.isEmpty,
  });

  factory CartDto.empty() => const CartDto(
        restaurant: null,
        lines: [],
        subtotal: 0,
        deliveryFee: 0,
        total: 0,
        itemCount: 0,
        isEmpty: true,
      );

  factory CartDto.fromDomain(Cart cart) {
    final restaurant = cart.restaurant;
    return CartDto(
      restaurant:
          restaurant == null ? null : RestaurantDto.fromDomain(restaurant),
      lines: cart.lines.map(CartLineDto.fromDomain).toList(growable: false),
      subtotal: cart.subtotal.amount,
      deliveryFee: cart.deliveryFee.amount,
      total: cart.total.amount,
      itemCount: cart.itemCount,
      isEmpty: cart.isEmpty,
    );
  }
}
