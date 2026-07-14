import '../../application/auth/session_store.dart';
import '../../application/ordering/cart_dto.dart';
import '../../application/ordering/cart_service.dart';
import '../../application/ordering/place_order.dart';
import '../common/view_model.dart';

class CheckoutViewModel extends ViewModel {
  final CartService _cart;
  final PlaceOrder _placeOrder;
  final SessionStore _session;

  bool isPlacing = false;
  String? errorMessage;
  CartDto cart;
  double balance;

  CheckoutViewModel(this._cart, this._placeOrder, this._session)
      : cart = _cart.current,
        balance = _session.current?.balance ?? 0 {
    bind(_cart.state.changes, (value) {
      cart = value;
      notify();
    });
    bind(_session.user.changes, (user) {
      balance = user?.balance ?? 0;
      notify();
    });
  }

  bool get canAfford => balance >= cart.total;

  void increment(int menuItemId) => _cart.increment(menuItemId);

  void decrement(int menuItemId) => _cart.decrement(menuItemId);

  void remove(int menuItemId) => _cart.remove(menuItemId);

  Future<bool> placeOrder() async {
    if (isPlacing) return false;
    isPlacing = true;
    notify();
    final result = await _placeOrder();
    isPlacing = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
