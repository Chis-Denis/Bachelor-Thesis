import 'package:flutter/foundation.dart';

import '../../restaurants/entities/menu_item.dart';
import '../../restaurants/entities/restaurant.dart';

class CartLine {
  final MenuItem menuItem;
  final int quantity;

  const CartLine({required this.menuItem, required this.quantity});

  double get lineTotal => menuItem.price * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        menuItem: menuItem,
        quantity: quantity ?? this.quantity,
      );
}

class CartController extends ChangeNotifier {
  Restaurant? _restaurant;
  final List<CartLine> _lines = [];

  Restaurant? get restaurant => _restaurant;

  List<CartLine> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;
  bool get isNotEmpty => _lines.isNotEmpty;

  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  double get subtotal => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  double get deliveryFee => _restaurant?.deliveryFee ?? 0;

  double get total => subtotal + deliveryFee;

  bool conflictsWith(Restaurant restaurant) =>
      _restaurant != null && _restaurant!.id != restaurant.id;

  void add(Restaurant restaurant, MenuItem item) {
    if (conflictsWith(restaurant)) {
      throw StateError(
        'Cart already contains items from another restaurant.',
      );
    }
    _restaurant = restaurant;
    final idx = _lines.indexWhere((l) => l.menuItem.id == item.id);
    if (idx >= 0) {
      _lines[idx] = _lines[idx].copyWith(
        quantity: _lines[idx].quantity + 1,
      );
    } else {
      _lines.add(CartLine(menuItem: item, quantity: 1));
    }
    notifyListeners();
  }

  void increment(int menuItemId) {
    final idx = _lines.indexWhere((l) => l.menuItem.id == menuItemId);
    if (idx < 0) return;
    _lines[idx] = _lines[idx].copyWith(quantity: _lines[idx].quantity + 1);
    notifyListeners();
  }

  void decrement(int menuItemId) {
    final idx = _lines.indexWhere((l) => l.menuItem.id == menuItemId);
    if (idx < 0) return;
    final current = _lines[idx];
    if (current.quantity <= 1) {
      _lines.removeAt(idx);
      if (_lines.isEmpty) _restaurant = null;
    } else {
      _lines[idx] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  void remove(int menuItemId) {
    final beforeLen = _lines.length;
    _lines.removeWhere((l) => l.menuItem.id == menuItemId);
    if (_lines.length == beforeLen) return;
    if (_lines.isEmpty) _restaurant = null;
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty && _restaurant == null) return;
    _lines.clear();
    _restaurant = null;
    notifyListeners();
  }
}
