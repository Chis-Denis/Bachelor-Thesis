import '../../domain/auth/auth_repository.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/password_hasher.dart';
import '../shared/operation_result.dart';
import 'session_store.dart';
import 'user_dto.dart';

class LoginUser {
  final AuthRepository _repository;
  final PasswordHasher _hasher;
  final SessionStore _session;

  const LoginUser(this._repository, this._hasher, this._session);

  Future<OperationResult<void>> call(String username, String password) async {
    try {
      final name = username.trim();
      if (name.isEmpty || password.isEmpty) {
        throw const InvalidCredentialsFailure();
      }
      final account = await _repository.findByUsername(name);
      if (account == null || !_hasher.verify(password, account.credential)) {
        throw const InvalidCredentialsFailure();
      }
      _session.set(UserDto.fromDomain(account.user));
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not sign in');
    }
  }
}
