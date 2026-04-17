import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../database/database.dart';
import '../../../exceptions/app_exception.dart';
import '../../../utils/password_hasher.dart';
import '../entities/user.dart';

class AuthRepository {
  final AppDatabase _database;
  final PasswordHasher _hasher;

  final ValueNotifier<User?> _currentUser = ValueNotifier<User?>(null);

  AuthRepository(this._database, this._hasher);

  ValueListenable<User?> get currentUserListenable => _currentUser;
  User? get currentUser => _currentUser.value;

  Future<User> register({
    required String username,
    required String password,
  }) async {
    final db = await _database.open();
    final salt = _hasher.generateSalt();
    final hash = _hasher.hash(password, salt);
    final createdAt = DateTime.now();

    try {
      final id = await db.insert(UsersTable.name, {
        UsersTable.username: username,
        UsersTable.passwordHash: hash,
        UsersTable.salt: salt,
        UsersTable.createdAt: createdAt.millisecondsSinceEpoch,
        UsersTable.balance: UsersTable.defaultBalance,
      });
      return User(
        id: id,
        username: username,
        createdAt: createdAt,
        balance: UsersTable.defaultBalance,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const AppException('Username already taken');
      }
      throw const AppException('Could not create account');
    }
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty || password.isEmpty) {
      throw const AppException('Invalid username or password');
    }

    final db = await _database.open();
    final rows = await db.query(
      UsersTable.name,
      where: '${UsersTable.username} = ?',
      whereArgs: [trimmed],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AppException('Invalid username or password');
    }

    final row = rows.first;
    final salt = row[UsersTable.salt] as String;
    final expectedHash = row[UsersTable.passwordHash] as String;
    if (!_hasher.verify(password, salt, expectedHash)) {
      throw const AppException('Invalid username or password');
    }

    final user = _userFromRow(row);
    _currentUser.value = user;
    return user;
  }

  Future<void> logout() async {
    _currentUser.value = null;
  }

  Future<User> adjustBalance(double delta) async {
    final user = _currentUser.value;
    if (user == null) {
      throw const AppException('Not signed in');
    }
    final newBalance = user.balance + delta;
    if (newBalance < 0) {
      throw const AppException('Insufficient funds');
    }

    final db = await _database.open();
    final count = await db.update(
      UsersTable.name,
      {UsersTable.balance: newBalance},
      where: '${UsersTable.id} = ?',
      whereArgs: [user.id],
    );
    if (count == 0) {
      throw const AppException('Could not update wallet');
    }

    final updated = user.copyWith(balance: newBalance);
    _currentUser.value = updated;
    return updated;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser.value;
    if (user == null) {
      throw const AppException('Not signed in');
    }
    if (newPassword.isEmpty) {
      throw const AppException('New password is required');
    }
    if (currentPassword == newPassword) {
      throw const AppException('New password must differ from current one');
    }

    final db = await _database.open();
    final rows = await db.query(
      UsersTable.name,
      columns: [UsersTable.salt, UsersTable.passwordHash],
      where: '${UsersTable.id} = ?',
      whereArgs: [user.id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw const AppException('Account not found');
    }

    final row = rows.first;
    final currentSalt = row[UsersTable.salt] as String;
    final currentHash = row[UsersTable.passwordHash] as String;
    if (!_hasher.verify(currentPassword, currentSalt, currentHash)) {
      throw const AppException('Current password is incorrect');
    }

    final newSalt = _hasher.generateSalt();
    final newHash = _hasher.hash(newPassword, newSalt);
    final count = await db.update(
      UsersTable.name,
      {
        UsersTable.passwordHash: newHash,
        UsersTable.salt: newSalt,
      },
      where: '${UsersTable.id} = ?',
      whereArgs: [user.id],
    );
    if (count == 0) {
      throw const AppException('Could not update password');
    }
  }

  User _userFromRow(Map<String, Object?> row) {
    return User(
      id: row[UsersTable.id] as int,
      username: row[UsersTable.username] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row[UsersTable.createdAt] as int,
      ),
      balance: (row[UsersTable.balance] as num?)?.toDouble() ??
          UsersTable.defaultBalance,
    );
  }
}
