import '../shared/hashed_password.dart';
import '../shared/money.dart';
import 'stored_account.dart';
import 'user.dart';

abstract interface class AuthRepository {
  Future<User> create({
    required String username,
    required HashedPassword credential,
    required Money initialBalance,
    required bool isBusinessOwner,
  });

  Future<StoredAccount?> findByUsername(String username);

  Future<StoredAccount?> findById(int userId);

  Future<void> updateBalance({required int userId, required Money balance});

  Future<void> updateCredential({
    required int userId,
    required HashedPassword credential,
  });
}
