import '../../domain/auth/auth_repository.dart';
import '../../domain/constants/wallet_constants.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/money.dart';
import '../shared/operation_result.dart';
import 'session_store.dart';
import 'user_dto.dart';

class AddFunds {
  final AuthRepository _repository;
  final SessionStore _session;

  const AddFunds(this._repository, this._session);

  Future<OperationResult<void>> call(double amount) async {
    try {
      if (amount <= 0) {
        throw const ValidationFailure('Enter an amount greater than zero');
      }
      if (amount > WalletConstants.maxTopUpAmount) {
        throw const ValidationFailure('That amount is too large');
      }
      final userId = _session.userId;
      if (userId == null) throw const NotAuthenticatedFailure();

      final account = await _repository.findById(userId);
      if (account == null) throw const AccountNotFoundFailure();

      final newBalance = account.user.balance + Money(amount);
      await _repository.updateBalance(userId: userId, balance: newBalance);
      _session.set(UserDto.fromDomain(account.user.withBalance(newBalance)));
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not add funds');
    }
  }
}
