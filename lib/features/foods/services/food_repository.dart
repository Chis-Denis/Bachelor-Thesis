import 'package:sqflite/sqflite.dart';

import '../../../database/database.dart';
import '../../../exceptions/app_exception.dart';
import '../../auth/services/auth_repository.dart';
import '../entities/food.dart';
import '../entities/food_data_type.dart';
import '../entities/food_source.dart';
import 'food_search_ranker.dart';
import 'usda_nutrition_service.dart';

class FoodSearchResult {
  final List<Food> foods;
  final String? remoteError;

  const FoodSearchResult({required this.foods, this.remoteError});
}

class FoodRepository {
  final AppDatabase _database;
  final AuthRepository _auth;
  final UsdaNutritionService _usda;

  FoodRepository(this._database, this._auth, this._usda);

  Future<FoodSearchResult> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const FoodSearchResult(foods: []);
    }

    final local = await _searchLocal(trimmed);
    final localNames = local.map((f) => f.name.toLowerCase()).toSet();
    final localRanked = _rank(local, trimmed);

    try {
      final remote = await _usda.search(trimmed);
      final filtered = remote
          .where((f) => !localNames.contains(f.name.toLowerCase()))
          .toList();
      final remoteRanked = _rank(filtered, trimmed);
      return FoodSearchResult(foods: [...localRanked, ...remoteRanked]);
    } on AppException catch (e) {
      return FoodSearchResult(foods: localRanked, remoteError: e.message);
    } catch (e) {
      return FoodSearchResult(
        foods: localRanked,
        remoteError: 'Lookup failed: $e',
      );
    }
  }

  List<Food> _rank(List<Food> foods, String query) {
    final scored = [
      for (final f in foods) (food: f, score: scoreFood(f, query)),
    ];
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byType = a.food.dataType.sortOrder
          .compareTo(b.food.dataType.sortOrder);
      if (byType != 0) return byType;
      return a.food.name.toLowerCase().compareTo(b.food.name.toLowerCase());
    });
    return scored.map((e) => e.food).toList(growable: false);
  }

  Future<List<Food>> _searchLocal(String query) async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final db = await _database.open();
    final rows = await db.query(
      FoodsTable.name,
      where: '${FoodsTable.userId} = ? AND ${FoodsTable.foodName} LIKE ?',
      whereArgs: [user.id, '%$query%'],
      orderBy: '${FoodsTable.foodName} COLLATE NOCASE ASC',
      limit: 50,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> upsert({
    required String name,
    int? fdcId,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required double sugar,
    required double servingSize,
    required String servingUnit,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final db = await _database.open();
    await db.insert(
      FoodsTable.name,
      {
        FoodsTable.userId: user.id,
        FoodsTable.fdcId: fdcId,
        FoodsTable.foodName: trimmed,
        FoodsTable.calories: calories,
        FoodsTable.protein: protein,
        FoodsTable.carbs: carbs,
        FoodsTable.fat: fat,
        FoodsTable.fiber: fiber,
        FoodsTable.sugar: sugar,
        FoodsTable.servingSize: servingSize,
        FoodsTable.servingUnit: servingUnit,
        FoodsTable.createdAt: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Food _fromRow(Map<String, Object?> row) {
    return Food(
      id: row[FoodsTable.id] as int?,
      fdcId: (row[FoodsTable.fdcId] as num?)?.toInt(),
      name: row[FoodsTable.foodName] as String,
      calories: (row[FoodsTable.calories] as num).toDouble(),
      protein: (row[FoodsTable.protein] as num).toDouble(),
      carbs: (row[FoodsTable.carbs] as num).toDouble(),
      fat: (row[FoodsTable.fat] as num).toDouble(),
      fiber: (row[FoodsTable.fiber] as num?)?.toDouble() ?? 0,
      sugar: (row[FoodsTable.sugar] as num?)?.toDouble() ?? 0,
      servingSize: (row[FoodsTable.servingSize] as num?)?.toDouble() ?? 1,
      servingUnit: (row[FoodsTable.servingUnit] as String?) ?? 'serving',
      source: FoodSource.local,
      dataType: FoodDataType.custom,
    );
  }
}
