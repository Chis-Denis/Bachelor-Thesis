import 'package:sqflite/sqflite.dart';

import '../../domain/constants/meal_constants.dart';
import '../../domain/foods/food.dart';
import '../../domain/foods/food_data_type.dart';
import '../../domain/foods/food_repository.dart';
import '../../domain/foods/food_source.dart';
import '../persistence/macros_row.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteFoodRepository implements FoodRepository {
  final SqfliteUnitOfWork _work;

  SqfliteFoodRepository(this._work);

  static const int _searchLimit = 50;

  @override
  Future<List<Food>> searchLocal({
    required int userId,
    required String query,
  }) async {
    final db = await _work.executor();
    final rows = await db.query(
      FoodsTable.name,
      where: '${FoodsTable.userId} = ? AND ${FoodsTable.foodName} LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: '${FoodsTable.foodName} COLLATE NOCASE ASC',
      limit: _searchLimit,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<void> upsert({required int userId, required Food food}) async {
    final db = await _work.executor();
    await db.insert(
      FoodsTable.name,
      {
        FoodsTable.userId: userId,
        FoodsTable.fdcId: food.fdcId,
        FoodsTable.foodName: food.name.trim(),
        ...MacrosRow.toColumns(food.macros, TableMacros.foods),
        FoodsTable.servingSize: food.servingSize,
        FoodsTable.servingUnit: food.servingUnit,
        FoodsTable.createdAt: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Food _fromRow(Map<String, Object?> row) => Food(
        id: (row[FoodsTable.id] as num?)?.toInt(),
        fdcId: (row[FoodsTable.fdcId] as num?)?.toInt(),
        name: row[FoodsTable.foodName] as String,
        macros: MacrosRow.read(row, TableMacros.foods),
        servingSize: (row[FoodsTable.servingSize] as num?)?.toDouble() ??
            MealConstants.defaultQuantity,
        servingUnit: (row[FoodsTable.servingUnit] as String?) ??
            MealConstants.defaultUnit,
        source: FoodSource.local,
        dataType: FoodDataType.custom,
      );
}
