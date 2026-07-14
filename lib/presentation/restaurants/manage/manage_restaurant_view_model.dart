import '../../../application/restaurants/delete_menu_item.dart';
import '../../../application/restaurants/get_my_restaurant.dart';
import '../../../application/restaurants/get_restaurant_menu.dart';
import '../../../application/restaurants/menu_item_dto.dart';
import '../../../application/restaurants/restaurant_dto.dart';
import '../../common/view_model.dart';

class ManageRestaurantViewModel extends ViewModel {
  final GetMyRestaurant _getMyRestaurant;
  final GetRestaurantMenu _getMenu;
  final DeleteMenuItem _deleteMenuItem;

  bool isLoading = true;
  String? errorMessage;
  RestaurantDto? restaurant;
  List<MenuItemDto> menu = const [];

  ManageRestaurantViewModel(
    this._getMyRestaurant,
    this._getMenu,
    this._deleteMenuItem,
  );

  Future<void> load() async {
    isLoading = true;
    notify();
    restaurant = await _getMyRestaurant();
    final current = restaurant;
    if (current != null) {
      final result = await _getMenu(current.id);
      menu = result.data ?? const [];
      if (!result.isSuccess) errorMessage = result.error;
    } else {
      menu = const [];
    }
    isLoading = false;
    notify();
  }

  Future<void> deleteItem(int menuItemId) async {
    final result = await _deleteMenuItem(menuItemId);
    if (!result.isSuccess) {
      errorMessage = result.error;
      notify();
      return;
    }
    await load();
  }

  void clearError() => errorMessage = null;
}
