import '../../domain/ordering/cart.dart';
import '../../domain/restaurants/menu_item.dart';
import '../../domain/restaurants/restaurant.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/money.dart';
import '../restaurants/menu_item_dto.dart';
import '../restaurants/restaurant_dto.dart';
import '../shared/observable_value.dart';
import '../shared/operation_result.dart';
import 'cart_dto.dart';

class CartService {
  final Cart _cart = Cart();
  final ObservableValue<CartDto> _state =
      ObservableValue<CartDto>(CartDto.empty());

  ObservableValue<CartDto> get state => _state;

  CartDto get current => _state.value;

  Restaurant? get restaurant => _cart.restaurant;

  List<CartLine> get lines => _cart.lines;

  Money get subtotal => _cart.subtotal;

  Money get deliveryFee => _cart.deliveryFee;

  Money get total => _cart.total;

  bool get isEmpty => _cart.isEmpty;

  bool conflictsWith(RestaurantDto restaurant) =>
      _cart.restaurant != null && _cart.restaurant!.id != restaurant.id;

  OperationResult<void> add(RestaurantDto restaurant, MenuItemDto item) {
    try {
      _cart.add(_toRestaurant(restaurant), _toMenuItem(item));
      _emit();
      return const OperationResult.ok();
    } on CartConflictFailure catch (failure) {
      return OperationResult.fail(failure.message);
    }
  }

  void increment(int menuItemId) {
    _cart.increment(menuItemId);
    _emit();
  }

  void decrement(int menuItemId) {
    _cart.decrement(menuItemId);
    _emit();
  }

  void remove(int menuItemId) {
    _cart.remove(menuItemId);
    _emit();
  }

  void clear() {
    _cart.clear();
    _emit();
  }

  void dispose() => _state.dispose();

  void _emit() => _state.value = CartDto.fromDomain(_cart);

  Restaurant _toRestaurant(RestaurantDto dto) => Restaurant(
        id: dto.id,
        name: dto.name,
        cuisine: dto.cuisine,
        deliveryFee: Money(dto.deliveryFee),
        rating: dto.rating,
        estimatedMinutes: dto.estimatedMinutes,
      );

  MenuItem _toMenuItem(MenuItemDto dto) => MenuItem(
        id: dto.id,
        restaurantId: dto.restaurantId,
        name: dto.name,
        description: dto.description,
        category: dto.category,
        price: Money(dto.price),
        macros: dto.macros.toDomain(),
      );
}
