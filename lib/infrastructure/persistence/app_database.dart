import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/constants/meal_constants.dart';
import '../../domain/constants/wallet_constants.dart';
import '../../domain/meals/meal_type.dart';
import '../../domain/restaurants/menu_item.dart';
import '../../domain/restaurants/restaurant.dart';
import 'database_constants.dart';
import 'tables.dart';

class AppDatabase {
  Database? _db;

  Future<Database> open() async {
    final existing = _db;
    if (existing != null) return existing;

    final path = join(await getDatabasesPath(), DatabaseConstants.fileName);
    return _db = await openDatabase(
      path,
      version: DatabaseConstants.version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => _ensureSchema(db),
      onUpgrade: (db, _, __) => _ensureSchema(db),
    );
  }

  Future<void> _ensureSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${UsersTable.name} (
        ${UsersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UsersTable.username} TEXT NOT NULL UNIQUE,
        ${UsersTable.passwordHash} TEXT NOT NULL,
        ${UsersTable.salt} TEXT NOT NULL,
        ${UsersTable.createdAt} INTEGER NOT NULL,
        ${UsersTable.balance} REAL NOT NULL DEFAULT ${WalletConstants.initialBalanceAmount},
        ${UsersTable.isBusinessOwner} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${MealsTable.name} (
        ${MealsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MealsTable.userId} INTEGER NOT NULL
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${MealsTable.mealName} TEXT NOT NULL,
        ${MealsTable.mealType} TEXT NOT NULL DEFAULT '${MealType.snack.name}',
        ${MealsTable.quantity} REAL NOT NULL DEFAULT ${MealConstants.defaultQuantity},
        ${MealsTable.unit} TEXT NOT NULL DEFAULT '${MealConstants.defaultUnit}',
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
        ${FoodsTable.servingSize} REAL NOT NULL DEFAULT ${MealConstants.defaultQuantity},
        ${FoodsTable.servingUnit} TEXT NOT NULL DEFAULT '${MealConstants.defaultUnit}',
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
        ${RestaurantsTable.estimatedMinutes} INTEGER NOT NULL DEFAULT ${Restaurant.defaultEstimatedMinutes},
        ${RestaurantsTable.createdAt} INTEGER NOT NULL,
        ${RestaurantsTable.ownerUserId} INTEGER
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE
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
        ${MenuItemsTable.category} TEXT NOT NULL DEFAULT '${MenuItem.defaultCategory}'
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
        ${OrderItemsTable.quantity} REAL NOT NULL DEFAULT ${MealConstants.defaultQuantity},
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${MealPreferencesTable.name} (
        ${MealPreferencesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MealPreferencesTable.userId} INTEGER NOT NULL UNIQUE
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${MealPreferencesTable.dietaryRestrictions} TEXT NOT NULL DEFAULT '',
        ${MealPreferencesTable.allergies} TEXT NOT NULL DEFAULT '',
        ${MealPreferencesTable.healthGoal} TEXT,
        ${MealPreferencesTable.dailyCalorieTarget} INTEGER,
        ${MealPreferencesTable.mealsPerDay} INTEGER NOT NULL DEFAULT 3
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${UserSettingsTable.name} (
        ${UserSettingsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${UserSettingsTable.userId} INTEGER NOT NULL UNIQUE
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${UserSettingsTable.defaultUnit} TEXT NOT NULL DEFAULT 'grams'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${IssuesTable.name} (
        ${IssuesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${IssuesTable.restaurantId} INTEGER NOT NULL
          REFERENCES ${RestaurantsTable.name}(${RestaurantsTable.id}) ON DELETE CASCADE,
        ${IssuesTable.orderId} INTEGER,
        ${IssuesTable.reporterUserId} INTEGER NOT NULL
          REFERENCES ${UsersTable.name}(${UsersTable.id}) ON DELETE CASCADE,
        ${IssuesTable.reporterUsername} TEXT NOT NULL,
        ${IssuesTable.description} TEXT NOT NULL DEFAULT '',
        ${IssuesTable.imageRef} TEXT NOT NULL,
        ${IssuesTable.createdAt} INTEGER NOT NULL,
        ${IssuesTable.status} TEXT NOT NULL DEFAULT 'open',
        ${IssuesTable.verdict} TEXT,
        ${IssuesTable.confidence} REAL,
        ${IssuesTable.evidenceJson} TEXT,
        ${IssuesTable.aiSummary} TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_issues_restaurant '
      'ON ${IssuesTable.name}(${IssuesTable.restaurantId})',
    );

    await _backfillColumns(db);
  }

  Future<void> _backfillColumns(Database db) async {
    await _addColumnIfMissing(db, MealsTable.name, MealsTable.mealType,
        "TEXT NOT NULL DEFAULT '${MealType.snack.name}'");
    await _addColumnIfMissing(db, MealsTable.name, MealsTable.quantity,
        'REAL NOT NULL DEFAULT ${MealConstants.defaultQuantity}');
    await _addColumnIfMissing(db, MealsTable.name, MealsTable.unit,
        "TEXT NOT NULL DEFAULT '${MealConstants.defaultUnit}'");
    await _addColumnIfMissing(
        db, MealsTable.name, MealsTable.fiber, 'REAL NOT NULL DEFAULT 0');
    await _addColumnIfMissing(
        db, MealsTable.name, MealsTable.sugar, 'REAL NOT NULL DEFAULT 0');
    await _addColumnIfMissing(db, UsersTable.name, UsersTable.balance,
        'REAL NOT NULL DEFAULT ${WalletConstants.initialBalanceAmount}');
    await _addColumnIfMissing(db, UsersTable.name, UsersTable.isBusinessOwner,
        'INTEGER NOT NULL DEFAULT 0');
    await _addColumnIfMissing(
        db, RestaurantsTable.name, RestaurantsTable.ownerUserId, 'INTEGER');
    await _addColumnIfMissing(db, MenuItemsTable.name, MenuItemsTable.fiber,
        'REAL NOT NULL DEFAULT 0');
    await _addColumnIfMissing(db, MenuItemsTable.name, MenuItemsTable.sugar,
        'REAL NOT NULL DEFAULT 0');
    await db.execute(
      "UPDATE ${MenuItemsTable.name} "
      "SET ${MenuItemsTable.description} = '' "
      "WHERE ${MenuItemsTable.description} IS NULL",
    );
    await _addColumnIfMissing(db, MenuItemsTable.name, MenuItemsTable.category,
        "TEXT NOT NULL DEFAULT '${MenuItem.defaultCategory}'");
    await _addColumnIfMissing(
        db,
        RestaurantsTable.name,
        RestaurantsTable.estimatedMinutes,
        'INTEGER NOT NULL DEFAULT ${Restaurant.defaultEstimatedMinutes}');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final existing = info.map((row) => row['name'] as String).toSet();
    if (!existing.contains(column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
