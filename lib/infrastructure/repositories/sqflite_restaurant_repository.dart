import '../../domain/restaurants/menu_item.dart';
import '../../domain/restaurants/menu_item_draft.dart';
import '../../domain/restaurants/menu_item_with_context.dart';
import '../../domain/restaurants/restaurant.dart';
import '../../domain/restaurants/restaurant_draft.dart';
import '../../domain/restaurants/restaurant_match.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/money.dart';
import '../persistence/macros_row.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteRestaurantRepository implements RestaurantRepository {
  final SqfliteUnitOfWork _work;

  SqfliteRestaurantRepository(this._work);

  static const String _aliasId = 'r_id';
  static const String _aliasName = 'r_name';
  static const String _aliasCuisine = 'r_cuisine';
  static const String _aliasDelivery = 'r_delivery';
  static const String _aliasRating = 'r_rating';
  static const String _aliasEstimated = 'r_estimated';

  @override
  Future<List<Restaurant>> findAll() async {
    final db = await _work.executor();
    final rows = await db.query(
      RestaurantsTable.name,
      orderBy: '${RestaurantsTable.rating} DESC, '
          '${RestaurantsTable.restaurantName} COLLATE NOCASE ASC',
    );
    return rows.map(_restaurantFromRow).toList(growable: false);
  }

  @override
  Future<List<RestaurantMatch>> findMatching(String query) async {
    final db = await _work.executor();
    final like = '%${query.trim()}%';

    final restaurantRows = await db.query(
      RestaurantsTable.name,
      where: '${RestaurantsTable.restaurantName} LIKE ?',
      whereArgs: [like],
    );

    final itemRows = await db.rawQuery(
      '''
      SELECT r.${RestaurantsTable.id} AS $_aliasId,
             r.${RestaurantsTable.restaurantName} AS $_aliasName,
             r.${RestaurantsTable.cuisine} AS $_aliasCuisine,
             r.${RestaurantsTable.deliveryFee} AS $_aliasDelivery,
             r.${RestaurantsTable.rating} AS $_aliasRating,
             r.${RestaurantsTable.estimatedMinutes} AS $_aliasEstimated,
             mi.*
      FROM ${MenuItemsTable.name} mi
      JOIN ${RestaurantsTable.name} r
        ON r.${RestaurantsTable.id} = mi.${MenuItemsTable.restaurantId}
      WHERE mi.${MenuItemsTable.itemName} LIKE ?
      ''',
      [like],
    );

    final restaurantsById = <int, Restaurant>{};
    for (final row in restaurantRows) {
      final restaurant = _restaurantFromRow(row);
      restaurantsById[restaurant.id] = restaurant;
    }

    final itemsByRestaurant = <int, List<MenuItem>>{};
    for (final row in itemRows) {
      final restaurantId = (row[_aliasId] as num).toInt();
      restaurantsById.putIfAbsent(
        restaurantId,
        () => Restaurant(
          id: restaurantId,
          name: row[_aliasName] as String,
          cuisine: row[_aliasCuisine] as String,
          deliveryFee: Money((row[_aliasDelivery] as num).toDouble()),
          rating: (row[_aliasRating] as num).toDouble(),
          estimatedMinutes: (row[_aliasEstimated] as num?)?.toInt() ??
              Restaurant.defaultEstimatedMinutes,
        ),
      );
      itemsByRestaurant
          .putIfAbsent(restaurantId, () => <MenuItem>[])
          .add(_menuItemFromRow(row, restaurantId: restaurantId));
    }

    return [
      for (final restaurant in restaurantsById.values)
        RestaurantMatch(
          restaurant: restaurant,
          matchedItems: itemsByRestaurant[restaurant.id] ?? const [],
        ),
    ];
  }

  @override
  Future<Restaurant?> findById(int id) async {
    final db = await _work.executor();
    final rows = await db.query(
      RestaurantsTable.name,
      where: '${RestaurantsTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _restaurantFromRow(rows.first);
  }

  @override
  Future<List<MenuItemWithContext>> catalog() async {
    final db = await _work.executor();
    final rows = await db.rawQuery(
      '''
      SELECT mi.*,
             r.${RestaurantsTable.id} AS $_aliasId,
             r.${RestaurantsTable.restaurantName} AS $_aliasName,
             r.${RestaurantsTable.cuisine} AS $_aliasCuisine
      FROM ${MenuItemsTable.name} mi
      JOIN ${RestaurantsTable.name} r
        ON r.${RestaurantsTable.id} = mi.${MenuItemsTable.restaurantId}
      ORDER BY mi.${MenuItemsTable.id} ASC
      ''',
    );
    return rows.map((row) {
      final restaurantId = (row[_aliasId] as num).toInt();
      return MenuItemWithContext(
        item: _menuItemFromRow(row, restaurantId: restaurantId),
        restaurantName: row[_aliasName] as String,
        cuisine: row[_aliasCuisine] as String,
      );
    }).toList(growable: false);
  }

  @override
  Future<List<MenuItem>> menuFor(int restaurantId) async {
    final db = await _work.executor();
    final rows = await db.query(
      MenuItemsTable.name,
      where: '${MenuItemsTable.restaurantId} = ?',
      whereArgs: [restaurantId],
      orderBy: '${MenuItemsTable.category} COLLATE NOCASE ASC, '
          '${MenuItemsTable.itemName} COLLATE NOCASE ASC',
    );
    return rows
        .map((row) => _menuItemFromRow(row, restaurantId: restaurantId))
        .toList(growable: false);
  }

  @override
  Future<Restaurant?> findByOwner(int ownerUserId) async {
    final db = await _work.executor();
    final rows = await db.query(
      RestaurantsTable.name,
      where: '${RestaurantsTable.ownerUserId} = ?',
      whereArgs: [ownerUserId],
      limit: 1,
    );
    return rows.isEmpty ? null : _restaurantFromRow(rows.first);
  }

  @override
  Future<int> createRestaurant({
    required int ownerUserId,
    required RestaurantDraft draft,
  }) async {
    final db = await _work.executor();
    return db.insert(RestaurantsTable.name, {
      RestaurantsTable.restaurantName: draft.name,
      RestaurantsTable.cuisine: draft.cuisine,
      RestaurantsTable.deliveryFee: draft.deliveryFee.amount,
      RestaurantsTable.rating: 0,
      RestaurantsTable.estimatedMinutes: draft.estimatedMinutes,
      RestaurantsTable.createdAt: DateTime.now().millisecondsSinceEpoch,
      RestaurantsTable.ownerUserId: ownerUserId,
    });
  }

  @override
  Future<void> updateRestaurant(Restaurant restaurant) async {
    final db = await _work.executor();
    await db.update(
      RestaurantsTable.name,
      {
        RestaurantsTable.restaurantName: restaurant.name,
        RestaurantsTable.cuisine: restaurant.cuisine,
        RestaurantsTable.deliveryFee: restaurant.deliveryFee.amount,
        RestaurantsTable.estimatedMinutes: restaurant.estimatedMinutes,
      },
      where: '${RestaurantsTable.id} = ?',
      whereArgs: [restaurant.id],
    );
  }

  @override
  Future<int> addMenuItem(MenuItemDraft draft) async {
    final db = await _work.executor();
    return db.insert(MenuItemsTable.name, {
      MenuItemsTable.restaurantId: draft.restaurantId,
      MenuItemsTable.itemName: draft.name,
      MenuItemsTable.description: draft.description,
      MenuItemsTable.category: draft.category,
      MenuItemsTable.price: draft.price.amount,
      ...MacrosRow.toColumns(draft.macros, TableMacros.menuItems),
    });
  }

  @override
  Future<void> updateMenuItem(MenuItem item) async {
    final db = await _work.executor();
    await db.update(
      MenuItemsTable.name,
      {
        MenuItemsTable.itemName: item.name,
        MenuItemsTable.description: item.description,
        MenuItemsTable.category: item.category,
        MenuItemsTable.price: item.price.amount,
        ...MacrosRow.toColumns(item.macros, TableMacros.menuItems),
      },
      where: '${MenuItemsTable.id} = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteMenuItem(int menuItemId) async {
    final db = await _work.executor();
    await db.delete(
      MenuItemsTable.name,
      where: '${MenuItemsTable.id} = ?',
      whereArgs: [menuItemId],
    );
  }

  Restaurant _restaurantFromRow(Map<String, Object?> row) => Restaurant(
        id: (row[RestaurantsTable.id] as num).toInt(),
        name: row[RestaurantsTable.restaurantName] as String,
        cuisine: row[RestaurantsTable.cuisine] as String,
        deliveryFee:
            Money((row[RestaurantsTable.deliveryFee] as num).toDouble()),
        rating: (row[RestaurantsTable.rating] as num).toDouble(),
        estimatedMinutes:
            (row[RestaurantsTable.estimatedMinutes] as num?)?.toInt() ??
                Restaurant.defaultEstimatedMinutes,
        ownerUserId: (row[RestaurantsTable.ownerUserId] as num?)?.toInt(),
      );

  MenuItem _menuItemFromRow(
    Map<String, Object?> row, {
    required int restaurantId,
  }) =>
      MenuItem(
        id: (row[MenuItemsTable.id] as num).toInt(),
        restaurantId: restaurantId,
        name: row[MenuItemsTable.itemName] as String,
        description: (row[MenuItemsTable.description] as String?) ?? '',
        category: (row[MenuItemsTable.category] as String?) ??
            MenuItem.defaultCategory,
        price: Money((row[MenuItemsTable.price] as num).toDouble()),
        macros: MacrosRow.read(row, TableMacros.menuItems),
      );
}
