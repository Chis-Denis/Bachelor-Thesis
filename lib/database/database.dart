import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UsersTable {
  UsersTable._();

  static const String name = 'users';
  static const String id = 'id';
  static const String username = 'username';
  static const String passwordHash = 'password_hash';
  static const String salt = 'salt';
  static const String createdAt = 'created_at';
  static const String balance = 'balance';

  static const double defaultBalance = 200;
}

class FoodsTable {
  FoodsTable._();

  static const String name = 'foods';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String fdcId = 'fdc_id';
  static const String foodName = 'food_name';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String servingSize = 'serving_size';
  static const String servingUnit = 'serving_unit';
  static const String createdAt = 'created_at';
}

class RestaurantsTable {
  RestaurantsTable._();

  static const String name = 'restaurants';
  static const String id = 'id';
  static const String restaurantName = 'name';
  static const String cuisine = 'cuisine';
  static const String deliveryFee = 'delivery_fee';
  static const String rating = 'rating';
  static const String estimatedMinutes = 'estimated_minutes';
  static const String createdAt = 'created_at';
}

class MenuItemsTable {
  MenuItemsTable._();

  static const String name = 'menu_items';
  static const String id = 'id';
  static const String restaurantId = 'restaurant_id';
  static const String itemName = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String category = 'category';

  static const String defaultCategory = 'Mains';
}

class OrdersTable {
  OrdersTable._();

  static const String name = 'orders';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String restaurantId = 'restaurant_id';
  static const String restaurantName = 'restaurant_name';
  static const String subtotal = 'subtotal';
  static const String deliveryFee = 'delivery_fee';
  static const String total = 'total';
  static const String createdAt = 'created_at';
}

class OrderItemsTable {
  OrderItemsTable._();

  static const String name = 'order_items';
  static const String id = 'id';
  static const String orderId = 'order_id';
  static const String menuItemId = 'menu_item_id';
  static const String itemName = 'name';
  static const String description = 'description';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
}

class MealsTable {
  MealsTable._();

  static const String name = 'meals';
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String mealName = 'meal_name';
  static const String mealType = 'meal_type';
  static const String quantity = 'quantity';
  static const String unit = 'unit';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fat = 'fat';
  static const String fiber = 'fiber';
  static const String sugar = 'sugar';
  static const String date = 'date';
  static const String notes = 'notes';
}

class AppDatabase {
  static const String _fileName = 'calorie_track.db';
  static const int _version = 9;

  Database? _db;

  Future<Database> open() async {
    final existing = _db;
    if (existing != null) return existing;

    final path = join(await getDatabasesPath(), _fileName);
    _db = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => _ensureSchema(db),
      onUpgrade: (db, _, __) => _ensureSchema(db),
    );
    return _db!;
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${UsersTable.name} (
        ${UsersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UsersTable.username} TEXT NOT NULL UNIQUE,
        ${UsersTable.passwordHash} TEXT NOT NULL,
        ${UsersTable.salt} TEXT NOT NULL,
        ${UsersTable.createdAt} INTEGER NOT NULL,
        ${UsersTable.balance} REAL NOT NULL DEFAULT ${UsersTable.defaultBalance}
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${MealsTable.name} (
        ${MealsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MealsTable.userId} INTEGER NOT NULL
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${MealsTable.mealName} TEXT NOT NULL,
        ${MealsTable.mealType} TEXT NOT NULL DEFAULT 'snack',
        ${MealsTable.quantity} REAL NOT NULL DEFAULT 1,
        ${MealsTable.unit} TEXT NOT NULL DEFAULT 'serving',
        ${MealsTable.calories} REAL NOT NULL,
        ${MealsTable.protein} REAL NOT NULL,
        ${MealsTable.carbs} REAL NOT NULL,
        ${MealsTable.fat} REAL NOT NULL,
        ${MealsTable.fiber} REAL NOT NULL DEFAULT 0,
        ${MealsTable.sugar} REAL NOT NULL DEFAULT 0,
        ${MealsTable.date} INTEGER NOT NULL,
        ${MealsTable.notes} TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_meals_user_id '
      'ON ${MealsTable.name}(${MealsTable.userId})',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${FoodsTable.name} (
        ${FoodsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${FoodsTable.userId} INTEGER NOT NULL
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${FoodsTable.fdcId} INTEGER,
        ${FoodsTable.foodName} TEXT NOT NULL COLLATE NOCASE,
        ${FoodsTable.calories} REAL NOT NULL,
        ${FoodsTable.protein} REAL NOT NULL,
        ${FoodsTable.carbs} REAL NOT NULL,
        ${FoodsTable.fat} REAL NOT NULL,
        ${FoodsTable.fiber} REAL NOT NULL DEFAULT 0,
        ${FoodsTable.sugar} REAL NOT NULL DEFAULT 0,
        ${FoodsTable.servingSize} REAL NOT NULL DEFAULT 1,
        ${FoodsTable.servingUnit} TEXT NOT NULL DEFAULT 'serving',
        ${FoodsTable.createdAt} INTEGER NOT NULL,
        UNIQUE(${FoodsTable.userId}, ${FoodsTable.foodName})
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_foods_user_id '
      'ON ${FoodsTable.name}(${FoodsTable.userId})',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${RestaurantsTable.name} (
        ${RestaurantsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${RestaurantsTable.restaurantName} TEXT NOT NULL COLLATE NOCASE,
        ${RestaurantsTable.cuisine} TEXT NOT NULL,
        ${RestaurantsTable.deliveryFee} REAL NOT NULL DEFAULT 0,
        ${RestaurantsTable.rating} REAL NOT NULL DEFAULT 0,
        ${RestaurantsTable.estimatedMinutes} INTEGER NOT NULL DEFAULT 30,
        ${RestaurantsTable.createdAt} INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_restaurants_name '
      'ON ${RestaurantsTable.name}(${RestaurantsTable.restaurantName} COLLATE NOCASE)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${MenuItemsTable.name} (
        ${MenuItemsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MenuItemsTable.restaurantId} INTEGER NOT NULL
          REFERENCES ${RestaurantsTable.name}(${RestaurantsTable.id}) ON DELETE CASCADE,
        ${MenuItemsTable.itemName} TEXT NOT NULL COLLATE NOCASE,
        ${MenuItemsTable.description} TEXT NOT NULL DEFAULT '',
        ${MenuItemsTable.price} REAL NOT NULL,
        ${MenuItemsTable.calories} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.protein} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.carbs} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.fat} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.fiber} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.sugar} REAL NOT NULL DEFAULT 0,
        ${MenuItemsTable.category} TEXT NOT NULL DEFAULT '${MenuItemsTable.defaultCategory}'
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_menu_items_restaurant '
      'ON ${MenuItemsTable.name}(${MenuItemsTable.restaurantId})',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_menu_items_name '
      'ON ${MenuItemsTable.name}(${MenuItemsTable.itemName} COLLATE NOCASE)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${OrdersTable.name} (
        ${OrdersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${OrdersTable.userId} INTEGER NOT NULL
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${OrdersTable.restaurantId} INTEGER,
        ${OrdersTable.restaurantName} TEXT NOT NULL,
        ${OrdersTable.subtotal} REAL NOT NULL DEFAULT 0,
        ${OrdersTable.deliveryFee} REAL NOT NULL DEFAULT 0,
        ${OrdersTable.total} REAL NOT NULL DEFAULT 0,
        ${OrdersTable.createdAt} INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_user_id '
      'ON ${OrdersTable.name}(${OrdersTable.userId})',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_created_at '
      'ON ${OrdersTable.name}(${OrdersTable.createdAt})',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${OrderItemsTable.name} (
        ${OrderItemsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${OrderItemsTable.orderId} INTEGER NOT NULL
          REFERENCES ${OrdersTable.name}(${OrdersTable.id}) ON DELETE CASCADE,
        ${OrderItemsTable.menuItemId} INTEGER,
        ${OrderItemsTable.itemName} TEXT NOT NULL,
        ${OrderItemsTable.description} TEXT NOT NULL DEFAULT '',
        ${OrderItemsTable.price} REAL NOT NULL,
        ${OrderItemsTable.quantity} REAL NOT NULL DEFAULT 1,
        ${OrderItemsTable.calories} REAL NOT NULL DEFAULT 0,
        ${OrderItemsTable.protein} REAL NOT NULL DEFAULT 0,
        ${OrderItemsTable.carbs} REAL NOT NULL DEFAULT 0,
        ${OrderItemsTable.fat} REAL NOT NULL DEFAULT 0,
        ${OrderItemsTable.fiber} REAL NOT NULL DEFAULT 0,
        ${OrderItemsTable.sugar} REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_order_items_order_id '
      'ON ${OrderItemsTable.name}(${OrderItemsTable.orderId})',
    );

    await _addColumnIfMissing(
      db,
      MealsTable.name,
      MealsTable.mealType,
      "TEXT NOT NULL DEFAULT 'snack'",
    );
    await _addColumnIfMissing(
      db,
      MealsTable.name,
      MealsTable.quantity,
      'REAL NOT NULL DEFAULT 1',
    );
    await _addColumnIfMissing(
      db,
      MealsTable.name,
      MealsTable.unit,
      "TEXT NOT NULL DEFAULT 'serving'",
    );
    await _addColumnIfMissing(
      db,
      MealsTable.name,
      MealsTable.fiber,
      'REAL NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      MealsTable.name,
      MealsTable.sugar,
      'REAL NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      UsersTable.name,
      UsersTable.balance,
      'REAL NOT NULL DEFAULT ${UsersTable.defaultBalance}',
    );
    await _addColumnIfMissing(
      db,
      MenuItemsTable.name,
      MenuItemsTable.fiber,
      'REAL NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      db,
      MenuItemsTable.name,
      MenuItemsTable.sugar,
      'REAL NOT NULL DEFAULT 0',
    );
    await db.execute(
      "UPDATE ${MenuItemsTable.name} "
      "SET ${MenuItemsTable.description} = '' "
      "WHERE ${MenuItemsTable.description} IS NULL",
    );
    await _addColumnIfMissing(
      db,
      MenuItemsTable.name,
      MenuItemsTable.category,
      "TEXT NOT NULL DEFAULT '${MenuItemsTable.defaultCategory}'",
    );
    await _addColumnIfMissing(
      db,
      RestaurantsTable.name,
      RestaurantsTable.estimatedMinutes,
      'INTEGER NOT NULL DEFAULT 30',
    );
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final existing = info.map((r) => r['name'] as String).toSet();
    if (!existing.contains(column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
