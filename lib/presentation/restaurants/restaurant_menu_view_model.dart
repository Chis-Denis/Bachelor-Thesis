import '../../application/restaurants/get_restaurant_menu.dart';
import '../../application/restaurants/menu_item_dto.dart';
import '../common/view_model.dart';

class RestaurantMenuViewModel extends ViewModel {
  final GetRestaurantMenu _getMenu;

  bool isLoading = true;
  String? errorMessage;
  List<MenuItemDto> items = const [];

  RestaurantMenuViewModel(this._getMenu);

  Future<void> load(int restaurantId) async {
    isLoading = true;
    notify();
    final result = await _getMenu(restaurantId);
    isLoading = false;
    if (result.isSuccess) {
      items = result.data ?? const [];
    } else {
      items = const [];
      errorMessage = result.error;
    }
    notify();
  }

  void clearError() => errorMessage = null;
}
