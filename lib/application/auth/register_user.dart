import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/password.dart';
import '../../domain/auth/username.dart';
import '../../domain/constants/wallet_constants.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/password_hasher.dart';
import '../shared/operation_result.dart';

class RegisterUser {
  final AuthRepository _repository;
  final PasswordHasher _hasher;

  const RegisterUser(this._repository, this._hasher);

  Future<OperationResult<int>> call(
    String username,
    String password, {
    bool isBusinessOwner = false,
  }) async {
    try {
      final name = Username(username);
      final pass = Password(password);
      final credential = _hasher.hash(pass.value);
      final user = await _repository.create(
        username: name.value,
        credential: credential,
        initialBalance: WalletConstants.initialBalance,
        isBusinessOwner: isBusinessOwner,
      );
      return OperationResult.ok(user.id);
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not create account');
    }
  }
}
