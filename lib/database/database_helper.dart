import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

/// Database helper class for managing SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database configuration
  static const String _databaseName = 'calorie_track.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'meals';

  // Column names
  static const String _columnId = 'id';
  static const String _columnMealName = 'meal_name';
  static const String _columnCalories = 'calories';
  static const String _columnProtein = 'protein';
  static const String _columnCarbs = 'carbs';
  static const String _columnFat = 'fat';
  static const String _columnDate = 'date';
  static const String _columnNotes = 'notes';

  /// Get the database instance, creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create the database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnMealName TEXT NOT NULL,
        $_columnCalories REAL NOT NULL,
        $_columnProtein REAL NOT NULL,
        $_columnCarbs REAL NOT NULL,
        $_columnFat REAL NOT NULL,
        $_columnDate INTEGER NOT NULL,
        $_columnNotes TEXT
      )
    ''');
  }

  /// Handle database upgrades (for future schema changes)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here when schema changes
    // For now, we'll just recreate the table if version changes
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  /// Insert a new meal into the database
  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    final map = meal.toMap();
    // Remove id from map for insert (auto-increment)
    map.remove(_columnId);
    return await db.insert(_tableName, map);
  }

  /// Get all meals from the database, ordered by date (newest first)
  Future<List<Meal>> getAllMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: '$_columnDate DESC',
    );
    return List.generate(maps.length, (i) => Meal.fromMap(maps[i]));
  }

  /// Get a meal by its ID
  Future<Meal?> getMealById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Meal.fromMap(maps.first);
  }

  /// Update an existing meal
  Future<int> updateMeal(Meal meal) async {
    final db = await database;
    return await db.update(
      _tableName,
      meal.toMap(),
      where: '$_columnId = ?',
      whereArgs: [meal.mealId],
    );
  }

  /// Delete a meal by its ID
  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  /// Delete all meals (useful for testing or reset)
  Future<int> deleteAllMeals() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  /// Get the count of meals in the database
  Future<int> getMealCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

