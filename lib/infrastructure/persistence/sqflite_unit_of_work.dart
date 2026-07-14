import 'package:sqflite/sqflite.dart';

import '../../domain/shared/unit_of_work.dart';
import 'app_database.dart';

class SqfliteUnitOfWork implements UnitOfWork {
  final AppDatabase _database;
  Transaction? _active;

  SqfliteUnitOfWork(this._database);

  Future<DatabaseExecutor> executor() async {
    final active = _active;
    if (active != null) return active;
    return _database.open();
  }

  @override
  Future<T> execute<T>(Future<T> Function() action) async {
    if (_active != null) return action();
    final db = await _database.open();
    return db.transaction((txn) async {
      _active = txn;
      try {
        return await action();
      } finally {
        _active = null;
      }
    });
  }
}
