import '../../../database/database.dart';
import '../entities/menu_item.dart';
import '../entities/restaurant.dart';

class RestaurantRepository {
  static const int _maxMatchedItemsPerRestaurant = 3;

  final AppDatabase _database;

  RestaurantRepository(this._database);

  Future<List<RestaurantWithMatches>> findAll() async {
    final db = await _database.open();
    final rows = await db.query(
      RestaurantsTable.name,
      orderBy: '${RestaurantsTable.rating} DESC, '
          '${RestaurantsTable.restaurantName} COLLATE NOCASE ASC',
    );
    return rows
        .map((r) => RestaurantWithMatches(
              restaurant: _restaurantFromRow(r),
              matchedItems: const [],
            ))
        .toList(growable: false);
  }

  Future<List<RestaurantWithMatches>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return findAll();

    final db = await _database.open();
    final like = '%$trimmed%';

    final restaurantRows = await db.query(
      RestaurantsTable.name,
      where: '${RestaurantsTable.restaurantName} LIKE ?',
      whereArgs: [like],
    );

    final itemRows = await db.rawQuery(
      '''
      SELECT r.${RestaurantsTable.id} AS r_id,
             r.${RestaurantsTable.restaurantName} AS r_name,
             r.${RestaurantsTable.cuisine} AS r_cuisine,
             r.${RestaurantsTable.deliveryFee} AS r_delivery,
             r.${RestaurantsTable.rating} AS r_rating,
             r.${RestaurantsTable.estimatedMinutes} AS r_estimated,
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
      final r = _restaurantFromRow(row);
      restaurantsById[r.id] = r;
    }

    final itemsByRestaurant = <int, List<MenuItem>>{};
    for (final row in itemRows) {
      final restaurantId = (row['r_id'] as num).toInt();
      restaurantsById.putIfAbsent(
        restaurantId,
        () => Restaurant(
          id: restaurantId,
          name: row['r_name'] as String,
          cuisine: row['r_cuisine'] as String,
          deliveryFee: (row['r_delivery'] as num).toDouble(),
          rating: (row['r_rating'] as num).toDouble(),
          estimatedMinutes: (row['r_estimated'] as num?)?.toInt() ?? 30,
        ),
      );
      final list = itemsByRestaurant.putIfAbsent(restaurantId, () => <MenuItem>[]);
      list.add(_menuItemFromRow(row, restaurantId: restaurantId));
    }

    final lowered = trimmed.toLowerCase();
    for (final list in itemsByRestaurant.values) {
      list.sort((a, b) => _itemScore(b, lowered).compareTo(_itemScore(a, lowered)));
    }

    final results = restaurantsById.values
        .map((r) => RestaurantWithMatches(
              restaurant: r,
              matchedItems: (itemsByRestaurant[r.id] ?? const [])
                  .take(_maxMatchedItemsPerRestaurant)
                  .toList(growable: false),
            ))
        .toList();

    results.sort((a, b) {
      final aScore = _restaurantScore(a, lowered);
      final bScore = _restaurantScore(b, lowered);
      final byScore = bScore.compareTo(aScore);
      if (byScore != 0) return byScore;
      final byRating = b.restaurant.rating.compareTo(a.restaurant.rating);
      if (byRating != 0) return byRating;
      return a.restaurant.name.toLowerCase()
          .compareTo(b.restaurant.name.toLowerCase());
    });

    return List.unmodifiable(results);
  }

  Future<List<MenuItem>> itemsForRestaurant(int restaurantId) async {
    final db = await _database.open();
    final rows = await db.query(
      MenuItemsTable.name,
      where: '${MenuItemsTable.restaurantId} = ?',
      whereArgs: [restaurantId],
      orderBy: '${MenuItemsTable.category} COLLATE NOCASE ASC, '
          '${MenuItemsTable.itemName} COLLATE NOCASE ASC',
    );
    return rows
        .map((r) => _menuItemFromRow(r, restaurantId: restaurantId))
        .toList(growable: false);
  }

  int _restaurantScore(RestaurantWithMatches r, String loweredQuery) {
    final name = r.restaurant.name.toLowerCase();
    int score = 0;
    if (name == loweredQuery) {
      score += 100;
    } else if (name.startsWith(loweredQuery)) {
      score += 70;
    } else if (name.contains(loweredQuery)) {
      score += 40;
    }

    if (r.matchedItems.isNotEmpty) {
      score += 10 + r.matchedItems.length * 5;
      final bestItem = r.matchedItems.first.name.toLowerCase();
      if (bestItem == loweredQuery) {
        score += 30;
      } else if (bestItem.startsWith(loweredQuery)) {
        score += 20;
      }
    }
    return score;
  }

  int _itemScore(MenuItem item, String loweredQuery) {
    final name = item.name.toLowerCase();
    if (name == loweredQuery) return 100;
    if (name.startsWith(loweredQuery)) return 70;
    if (name.contains(loweredQuery)) return 40;
    return 0;
  }

  Restaurant _restaurantFromRow(Map<String, Object?> row) {
    return Restaurant(
      id: (row[RestaurantsTable.id] as num).toInt(),
      name: row[RestaurantsTable.restaurantName] as String,
      cuisine: row[RestaurantsTable.cuisine] as String,
      deliveryFee: (row[RestaurantsTable.deliveryFee] as num).toDouble(),
      rating: (row[RestaurantsTable.rating] as num).toDouble(),
      estimatedMinutes:
          (row[RestaurantsTable.estimatedMinutes] as num?)?.toInt() ?? 30,
    );
  }

  MenuItem _menuItemFromRow(
    Map<String, Object?> row, {
    required int restaurantId,
  }) {
    return MenuItem(
      id: (row[MenuItemsTable.id] as num).toInt(),
      restaurantId: restaurantId,
      name: row[MenuItemsTable.itemName] as String,
      description: (row[MenuItemsTable.description] as String?) ?? '',
      category: (row[MenuItemsTable.category] as String?) ??
          MenuItemsTable.defaultCategory,
      price: (row[MenuItemsTable.price] as num).toDouble(),
      calories: (row[MenuItemsTable.calories] as num?)?.toDouble() ?? 0,
      protein: (row[MenuItemsTable.protein] as num?)?.toDouble() ?? 0,
      carbs: (row[MenuItemsTable.carbs] as num?)?.toDouble() ?? 0,
      fat: (row[MenuItemsTable.fat] as num?)?.toDouble() ?? 0,
      fiber: (row[MenuItemsTable.fiber] as num?)?.toDouble() ?? 0,
      sugar: (row[MenuItemsTable.sugar] as num?)?.toDouble() ?? 0,
    );
  }
}
