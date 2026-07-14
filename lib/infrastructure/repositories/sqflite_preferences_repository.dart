import 'package:sqflite/sqflite.dart';

import '../../domain/constants/preferences_constants.dart';
import '../../domain/preferences/dietary_restriction.dart';
import '../../domain/preferences/food_allergy.dart';
import '../../domain/preferences/health_goal.dart';
import '../../domain/preferences/meal_preferences.dart';
import '../../domain/preferences/preferences_repository.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqflitePreferencesRepository implements PreferencesRepository {
  final SqfliteUnitOfWork _work;

  SqflitePreferencesRepository(this._work);

  @override
  Future<MealPreferences?> findByUserId(int userId) async {
    final db = await _work.executor();
    final rows = await db.query(
      MealPreferencesTable.name,
      where: '${MealPreferencesTable.userId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> save(MealPreferences preferences) async {
    final db = await _work.executor();
    await db.insert(
      MealPreferencesTable.name,
      _toRow(preferences),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  MealPreferences _fromRow(Map<String, Object?> row) => MealPreferences(
        userId: row[MealPreferencesTable.userId] as int,
        dietaryRestrictions: _parseRestrictions(
          row[MealPreferencesTable.dietaryRestrictions] as String? ?? '',
        ),
        allergies: _parseAllergies(
          row[MealPreferencesTable.allergies] as String? ?? '',
        ),
        healthGoal: _parseHealthGoal(
          row[MealPreferencesTable.healthGoal] as String?,
        ),
        dailyCalorieTarget:
            row[MealPreferencesTable.dailyCalorieTarget] as int?,
        mealsPerDay: row[MealPreferencesTable.mealsPerDay] as int? ??
            PreferencesConstants.defaultMealsPerDay,
      );

  Map<String, Object?> _toRow(MealPreferences prefs) => {
        MealPreferencesTable.userId: prefs.userId,
        MealPreferencesTable.dietaryRestrictions:
            prefs.dietaryRestrictions.map((r) => r.name).join(','),
        MealPreferencesTable.allergies:
            prefs.allergies.map((a) => a.name).join(','),
        MealPreferencesTable.healthGoal: prefs.healthGoal?.name,
        MealPreferencesTable.dailyCalorieTarget: prefs.dailyCalorieTarget,
        MealPreferencesTable.mealsPerDay: prefs.mealsPerDay,
      };

  Set<DietaryRestriction> _parseRestrictions(String raw) {
    if (raw.isEmpty) return {};
    final result = <DietaryRestriction>{};
    for (final name in raw.split(',')) {
      try {
        result.add(DietaryRestriction.values.byName(name));
      } catch (_) {}
    }
    return result;
  }

  Set<FoodAllergy> _parseAllergies(String raw) {
    if (raw.isEmpty) return {};
    final result = <FoodAllergy>{};
    for (final name in raw.split(',')) {
      try {
        result.add(FoodAllergy.values.byName(name));
      } catch (_) {}
    }
    return result;
  }

  HealthGoal? _parseHealthGoal(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return HealthGoal.values.byName(raw);
    } catch (_) {
      return null;
    }
  }
}
