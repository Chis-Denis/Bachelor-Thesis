import 'package:sqflite/sqflite.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/stored_account.dart';
import '../../domain/auth/user.dart';
import '../../domain/constants/wallet_constants.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/hashed_password.dart';
import '../../domain/shared/money.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteAuthRepository implements AuthRepository {
  final SqfliteUnitOfWork _work;

  SqfliteAuthRepository(this._work);

  @override
  Future<User> create({
    required String username,
    required HashedPassword credential,
    required Money initialBalance,
    required bool isBusinessOwner,
  }) async {
    final db = await _work.executor();
    final createdAt = DateTime.now();
    try {
      final id = await db.insert(UsersTable.name, {
        UsersTable.username: username,
        UsersTable.passwordHash: credential.hash,
        UsersTable.salt: credential.salt,
        UsersTable.createdAt: createdAt.millisecondsSinceEpoch,
        UsersTable.balance: initialBalance.amount,
        UsersTable.isBusinessOwner: isBusinessOwner ? 1 : 0,
      });
      return User(
        id: id,
        username: username,
        createdAt: createdAt,
        balance: initialBalance,
        isBusinessOwner: isBusinessOwner,
      );
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const UsernameTakenFailure();
      }
      throw const AccountCreationFailure();
    }
  }

  @override
  Future<StoredAccount?> findByUsername(String username) async {
    final db = await _work.executor();
    final rows = await db.query(
      UsersTable.name,
      where: '${UsersTable.username} = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );
    return rows.isEmpty ? null : _accountFromRow(rows.first);
  }

  @override
  Future<StoredAccount?> findById(int userId) async {
    final db = await _work.executor();
    final rows = await db.query(
      UsersTable.name,
      where: '${UsersTable.id} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : _accountFromRow(rows.first);
  }

  @override
  Future<void> updateBalance({
    required int userId,
    required Money balance,
  }) async {
    final db = await _work.executor();
    final count = await db.update(
      UsersTable.name,
      {UsersTable.balance: balance.amount},
      where: '${UsersTable.id} = ?',
      whereArgs: [userId],
    );
    if (count == 0) throw const PersistenceFailure('Could not update wallet');
  }

  @override
  Future<void> updateCredential({
    required int userId,
    required HashedPassword credential,
  }) async {
    final db = await _work.executor();
    final count = await db.update(
      UsersTable.name,
      {
        UsersTable.passwordHash: credential.hash,
        UsersTable.salt: credential.salt,
      },
      where: '${UsersTable.id} = ?',
      whereArgs: [userId],
    );
    if (count == 0) throw const PersistenceFailure('Could not update password');
  }

  StoredAccount _accountFromRow(Map<String, Object?> row) {
    final balance = (row[UsersTable.balance] as num?)?.toDouble() ??
        WalletConstants.initialBalanceAmount;
    return StoredAccount(
      user: User(
        id: row[UsersTable.id] as int,
        username: row[UsersTable.username] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            row[UsersTable.createdAt] as int),
        balance: Money(balance),
        isBusinessOwner: (row[UsersTable.isBusinessOwner] as int? ?? 0) == 1,
      ),
      credential: HashedPassword(
        salt: row[UsersTable.salt] as String,
        hash: row[UsersTable.passwordHash] as String,
      ),
    );
  }
}
