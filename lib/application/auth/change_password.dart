import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/password.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/password_hasher.dart';
import '../shared/operation_result.dart';
import 'session_store.dart';

class ChangePassword {
  final AuthRepository _repository;
  final PasswordHasher _hasher;
  final SessionStore _session;

  const ChangePassword(this._repository, this._hasher, this._session);

  Future<OperationResult<void>> call(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();
      final nextPassword = Password(newPassword);
      final account = await _repository.findById(userId);
      if (account == null) throw const AccountNotFoundFailure();
      if (!_hasher.verify(currentPassword, account.credential)) {
        throw const IncorrectPasswordFailure();
      }
      if (currentPassword == newPassword) {
        throw const PasswordUnchangedFailure();
      }
      final credential = _hasher.hash(nextPassword.value);
      await _repository.updateCredential(
          userId: userId, credential: credential);
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not update password');
    }
  }
}
