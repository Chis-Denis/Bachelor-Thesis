import '../persistence/app_database.dart';
import '../persistence/tables.dart';
import 'seed_data.dart';

class RestaurantSeeder {
  final AppDatabase _database;

  RestaurantSeeder(this._database);

  Future<void> ensureSeeded() async {
    final db = await _database.open();
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${RestaurantsTable.name}',
    );
    final count = (countRows.first['c'] as num?)?.toInt() ?? 0;
    if (count > 0) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      for (final restaurant in seedRestaurants) {
        final restaurantId = await txn.insert(RestaurantsTable.name, {
          RestaurantsTable.restaurantName: restaurant.name,
          RestaurantsTable.cuisine: restaurant.cuisine,
          RestaurantsTable.deliveryFee: restaurant.deliveryFee,
          RestaurantsTable.rating: restaurant.rating,
          RestaurantsTable.estimatedMinutes: restaurant.estimatedMinutes,
          RestaurantsTable.createdAt: now,
        });
        for (final item in restaurant.items) {
          await txn.insert(MenuItemsTable.name, {
            MenuItemsTable.restaurantId: restaurantId,
            MenuItemsTable.itemName: item.name,
            MenuItemsTable.description: item.description,
            MenuItemsTable.category: item.category,
            MenuItemsTable.price: item.price,
            MenuItemsTable.calories: item.calories,
            MenuItemsTable.protein: item.protein,
            MenuItemsTable.carbs: item.carbs,
            MenuItemsTable.fat: item.fat,
            MenuItemsTable.fiber: item.fiber,
            MenuItemsTable.sugar: item.sugar,
          });
        }
      }
    });
  }
}
