import 'menu_item.dart';
import 'menu_item_draft.dart';
import 'menu_item_with_context.dart';
import 'restaurant.dart';
import 'restaurant_draft.dart';
import 'restaurant_match.dart';

abstract interface class RestaurantRepository {
  Future<List<Restaurant>> findAll();

  Future<Restaurant?> findById(int id);

  Future<Restaurant?> findByOwner(int ownerUserId);

  Future<List<RestaurantMatch>> findMatching(String query);

  Future<List<MenuItem>> menuFor(int restaurantId);

  Future<List<MenuItemWithContext>> catalog();

  Future<int> createRestaurant({
    required int ownerUserId,
    required RestaurantDraft draft,
  });

  Future<void> updateRestaurant(Restaurant restaurant);

  Future<int> addMenuItem(MenuItemDraft draft);

  Future<void> updateMenuItem(MenuItem item);

  Future<void> deleteMenuItem(int menuItemId);
}
