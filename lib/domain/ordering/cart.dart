import '../restaurants/menu_item.dart';
import '../restaurants/restaurant.dart';
import '../shared/failures.dart';
import '../shared/money.dart';

class CartLine {
  final MenuItem item;
  final int quantity;

  const CartLine({required this.item, required this.quantity});

  Money get lineTotal => item.price.scale(quantity.toDouble());

  CartLine withQuantity(int newQuantity) =>
      CartLine(item: item, quantity: newQuantity);
}

class Cart {
  Restaurant? _restaurant;
  final List<CartLine> _lines = [];

  Restaurant? get restaurant => _restaurant;

  List<CartLine> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;

  bool get isNotEmpty => _lines.isNotEmpty;

  int get itemCount => _lines.fold(0, (sum, line) => sum + line.quantity);

  Money get subtotal =>
      _lines.fold(Money.zero, (sum, line) => sum + line.lineTotal);

  Money get deliveryFee => _restaurant?.deliveryFee ?? Money.zero;

  Money get total => subtotal + deliveryFee;

  bool conflictsWith(Restaurant candidate) =>
      _restaurant != null && _restaurant!.id != candidate.id;

  void add(Restaurant restaurant, MenuItem item) {
    if (conflictsWith(restaurant)) {
      throw const CartConflictFailure();
    }
    _restaurant = restaurant;
    final index = _lines.indexWhere((line) => line.item.id == item.id);
    if (index >= 0) {
      _lines[index] = _lines[index].withQuantity(_lines[index].quantity + 1);
    } else {
      _lines.add(CartLine(item: item, quantity: 1));
    }
  }

  void increment(int menuItemId) {
    final index = _lines.indexWhere((line) => line.item.id == menuItemId);
    if (index < 0) return;
    _lines[index] = _lines[index].withQuantity(_lines[index].quantity + 1);
  }

  void decrement(int menuItemId) {
    final index = _lines.indexWhere((line) => line.item.id == menuItemId);
    if (index < 0) return;
    final current = _lines[index];
    if (current.quantity <= 1) {
      _lines.removeAt(index);
      if (_lines.isEmpty) _restaurant = null;
    } else {
      _lines[index] = current.withQuantity(current.quantity - 1);
    }
  }

  void remove(int menuItemId) {
    _lines.removeWhere((line) => line.item.id == menuItemId);
    if (_lines.isEmpty) _restaurant = null;
  }

  void clear() {
    _lines.clear();
    _restaurant = null;
  }
}
