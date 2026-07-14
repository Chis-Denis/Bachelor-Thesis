import '../meals/meals_store.dart';
import '../ordering/cart_service.dart';
import 'session_store.dart';

class LogoutUser {
  final SessionStore _session;
  final MealsStore _meals;
  final CartService _cart;

  const LogoutUser(this._session, this._meals, this._cart);

  void call() {
    _session.clear();
    _meals.clear();
    _cart.clear();
  }
}
