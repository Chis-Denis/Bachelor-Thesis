import 'package:sqflite/sqflite.dart';

import '../../domain/settings/food_unit.dart';
import '../../domain/settings/settings_repository.dart';
import '../../domain/settings/user_settings.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteSettingsRepository implements SettingsRepository {
  final SqfliteUnitOfWork _work;

  SqfliteSettingsRepository(this._work);

  @override
  Future<UserSettings?> findByUserId(int userId) async {
    final db = await _work.executor();
    final rows = await db.query(
      UserSettingsTable.name,
      where: '${UserSettingsTable.userId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> save(UserSettings settings) async {
    final db = await _work.executor();
    await db.insert(
      UserSettingsTable.name,
      _toRow(settings),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  UserSettings _fromRow(Map<String, Object?> row) => UserSettings(
        userId: row[UserSettingsTable.userId] as int,
        defaultUnit: _parseUnit(row[UserSettingsTable.defaultUnit] as String?),
      );

  Map<String, Object?> _toRow(UserSettings settings) => {
        UserSettingsTable.userId: settings.userId,
        UserSettingsTable.defaultUnit: settings.defaultUnit.name,
      };

  FoodUnit _parseUnit(String? raw) {
    if (raw == null) return FoodUnit.grams;
    try {
      return FoodUnit.values.byName(raw);
    } catch (_) {
      return FoodUnit.grams;
    }
  }
}
