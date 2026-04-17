import 'package:flutter/foundation.dart';

import '../../../database/database.dart';
import '../../../exceptions/app_exception.dart';
import '../../auth/entities/user.dart';
import '../../auth/services/auth_repository.dart';
import '../../foods/services/food_repository.dart';
import '../entities/meal.dart';
import '../entities/meal_type.dart';

class MealRepository {
  final AppDatabase _database;
  final AuthRepository _auth;
  final FoodRepository _foods;

  final ValueNotifier<List<Meal>> _meals = ValueNotifier<List<Meal>>(const []);

  MealRepository(this._database, this._auth, this._foods);

  ValueListenable<List<Meal>> get mealsListenable => _meals;
  List<Meal> get meals => _meals.value;

  Future<void> load() async {
    final user = _auth.currentUser;
    if (user == null) {
      _meals.value = const [];
      return;
    }
    final db = await _database.open();
    final rows = await db.query(
      MealsTable.name,
      where: '${MealsTable.userId} = ?',
      whereArgs: [user.id],
      orderBy: '${MealsTable.date} DESC',
    );
    _meals.value = rows.map(_mealFromRow).toList(growable: false);
  }

  Future<Meal?> findById(int id) async {
    final user = _requireUser();
    final db = await _database.open();
    final rows = await db.query(
      MealsTable.name,
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [id, user.id],
      limit: 1,
    );
    return rows.isEmpty ? null : _mealFromRow(rows.first);
  }

  Future<void> add({
    required String name,
    required MealType type,
    required double quantity,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    required double sugar,
    DateTime? date,
    String? notes,
  }) async {
    final trimmed = name.trim();
    final trimmedUnit = unit.trim();
    _validate(
      trimmed,
      trimmedUnit,
      quantity,
      calories,
      protein,
      carbs,
      fat,
      fiber,
      sugar,
    );
    final user = _requireUser();
    final createdAt = date ?? DateTime.now();

    final db = await _database.open();
    final id = await db.insert(MealsTable.name, {
      MealsTable.userId: user.id,
      MealsTable.mealName: trimmed,
      MealsTable.mealType: type.name,
      MealsTable.quantity: quantity,
      MealsTable.unit: trimmedUnit,
      MealsTable.calories: calories,
      MealsTable.protein: protein,
      MealsTable.carbs: carbs,
      MealsTable.fat: fat,
      MealsTable.fiber: fiber,
      MealsTable.sugar: sugar,
      MealsTable.date: createdAt.millisecondsSinceEpoch,
      MealsTable.notes: notes,
    });

    final inserted = Meal(
      id: id,
      name: trimmed,
      type: type,
      quantity: quantity,
      unit: trimmedUnit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      date: createdAt,
      notes: notes,
    );
    final next = [inserted, ..._meals.value]
      ..sort((a, b) => b.date.compareTo(a.date));
    _meals.value = List.unmodifiable(next);

    await _foods.upsert(
      name: trimmed,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      servingSize: quantity,
      servingUnit: trimmedUnit,
    );
  }

  Future<void> update(Meal meal) async {
    final trimmed = meal.name.trim();
    final trimmedUnit = meal.unit.trim();
    _validate(
      trimmed,
      trimmedUnit,
      meal.quantity,
      meal.calories,
      meal.protein,
      meal.carbs,
      meal.fat,
      meal.fiber,
      meal.sugar,
    );
    final user = _requireUser();

    final db = await _database.open();
    final count = await db.update(
      MealsTable.name,
      {
        MealsTable.mealName: trimmed,
        MealsTable.mealType: meal.type.name,
        MealsTable.quantity: meal.quantity,
        MealsTable.unit: trimmedUnit,
        MealsTable.calories: meal.calories,
        MealsTable.protein: meal.protein,
        MealsTable.carbs: meal.carbs,
        MealsTable.fat: meal.fat,
        MealsTable.fiber: meal.fiber,
        MealsTable.sugar: meal.sugar,
        MealsTable.date: meal.date.millisecondsSinceEpoch,
        MealsTable.notes: meal.notes,
      },
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [meal.id, user.id],
    );
    if (count == 0) {
      throw const AppException('Meal not found');
    }

    final updated = meal.copyWith(name: trimmed, unit: trimmedUnit);
    final next = _meals.value.map((m) => m.id == meal.id ? updated : m).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _meals.value = List.unmodifiable(next);

    await _foods.upsert(
      name: trimmed,
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      fiber: meal.fiber,
      sugar: meal.sugar,
      servingSize: meal.quantity,
      servingUnit: trimmedUnit,
    );
  }

  Future<void> remove(int id) async {
    final user = _requireUser();
    final db = await _database.open();
    await db.delete(
      MealsTable.name,
      where: '${MealsTable.id} = ? AND ${MealsTable.userId} = ?',
      whereArgs: [id, user.id],
    );
    _meals.value =
        _meals.value.where((m) => m.id != id).toList(growable: false);
  }

  void _validate(
    String name,
    String unit,
    double quantity,
    double calories,
    double protein,
    double carbs,
    double fat,
    double fiber,
    double sugar,
  ) {
    if (name.isEmpty) {
      throw const AppException('Meal name is required');
    }
    if (unit.isEmpty) {
      throw const AppException('Unit is required');
    }
    if (quantity <= 0) {
      throw const AppException('Quantity must be greater than 0');
    }
    if (calories < 0 ||
        protein < 0 ||
        carbs < 0 ||
        fat < 0 ||
        fiber < 0 ||
        sugar < 0) {
      throw const AppException('Numeric values must be 0 or greater');
    }
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('Not signed in');
    return user;
  }

  Meal _mealFromRow(Map<String, Object?> row) {
    return Meal(
      id: row[MealsTable.id] as int,
      name: row[MealsTable.mealName] as String,
      type: MealType.parse(row[MealsTable.mealType] as String?),
      quantity: _asDouble(row[MealsTable.quantity]) ?? 1,
      unit: (row[MealsTable.unit] as String?) ?? 'serving',
      calories: (row[MealsTable.calories] as num).toDouble(),
      protein: (row[MealsTable.protein] as num).toDouble(),
      carbs: (row[MealsTable.carbs] as num).toDouble(),
      fat: (row[MealsTable.fat] as num).toDouble(),
      fiber: _asDouble(row[MealsTable.fiber]) ?? 0,
      sugar: _asDouble(row[MealsTable.sugar]) ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(row[MealsTable.date] as int),
      notes: row[MealsTable.notes] as String?,
    );
  }

  double? _asDouble(Object? v) => v is num ? v.toDouble() : null;
}
