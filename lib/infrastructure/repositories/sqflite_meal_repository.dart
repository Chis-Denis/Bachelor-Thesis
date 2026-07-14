import '../../domain/constants/meal_constants.dart';
import '../../domain/meals/meal.dart';
import '../../domain/meals/meal_draft.dart';
import '../../domain/meals/meal_repository.dart';
import '../../domain/meals/meal_type.dart';
import '../../domain/shared/failures.dart';
import '../persistence/macros_row.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteMealRepository implements MealRepository {
  final SqfliteUnitOfWork _work;

  SqfliteMealRepository(this._work);

  @override
  Future<List<Meal>> findByUser(int userId) async {
    final db = await _work.executor();
    final rows = await db.query(
      MealsTable.name,
      where: '${MealsTable.userId} = ?',
      whereArgs: [userId],
      orderBy: '${MealsTable.date} DESC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<Meal?> findById({required int mealId, required int userId}) async {
    final db = await _work.executor();
    final rows = await db.query(
      MealsTable.name,
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [mealId, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<Meal> add({required int userId, required MealDraft draft}) async {
    final db = await _work.executor();
    final id = await db.insert(MealsTable.name, {
      MealsTable.userId: userId,
      MealsTable.mealName: draft.name,
      MealsTable.mealType: draft.type.name,
      MealsTable.quantity: draft.quantity.value,
      MealsTable.unit: draft.unit,
      ...MacrosRow.toColumns(draft.macros, TableMacros.meals),
      MealsTable.date: draft.date.millisecondsSinceEpoch,
      MealsTable.notes: draft.notes,
    });
    return Meal(
      id: id,
      name: draft.name,
      type: draft.type,
      quantity: draft.quantity.value,
      unit: draft.unit,
      macros: draft.macros,
      date: draft.date,
      notes: draft.notes,
    );
  }

  @override
  Future<void> update({required int userId, required Meal meal}) async {
    final db = await _work.executor();
    final count = await db.update(
      MealsTable.name,
      {
        MealsTable.mealName: meal.name,
        MealsTable.mealType: meal.type.name,
        MealsTable.quantity: meal.quantity,
        MealsTable.unit: meal.unit,
        ...MacrosRow.toColumns(meal.macros, TableMacros.meals),
        MealsTable.date: meal.date.millisecondsSinceEpoch,
        MealsTable.notes: meal.notes,
      },
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [meal.id, userId],
    );
    if (count == 0) throw const MealNotFoundFailure();
  }

  @override
  Future<void> remove({required int mealId, required int userId}) async {
    final db = await _work.executor();
    await db.delete(
      MealsTable.name,
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [mealId, userId],
    );
  }

  Meal _fromRow(Map<String, Object?> row) {
    final quantity = row[MealsTable.quantity];
    return Meal(
      id: row[MealsTable.id] as int,
      name: row[MealsTable.mealName] as String,
      type: MealType.parse(row[MealsTable.mealType] as String?),
      quantity:
          quantity is num ? quantity.toDouble() : MealConstants.defaultQuantity,
      unit: (row[MealsTable.unit] as String?) ?? MealConstants.defaultUnit,
      macros: MacrosRow.read(row, TableMacros.meals),
      date: DateTime.fromMillisecondsSinceEpoch(row[MealsTable.date] as int),
      notes: row[MealsTable.notes] as String?,
    );
  }
}
