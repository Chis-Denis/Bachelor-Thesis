sealed class DomainFailure implements Exception {
  final String message;

  const DomainFailure(this.message);

  @override
  String toString() => message;
}

final class ValidationFailure extends DomainFailure {
  const ValidationFailure(super.message);
}

final class InvalidCredentialsFailure extends DomainFailure {
  const InvalidCredentialsFailure() : super('Invalid username or password');
}

final class UsernameTakenFailure extends DomainFailure {
  const UsernameTakenFailure() : super('Username already taken');
}

final class AccountCreationFailure extends DomainFailure {
  const AccountCreationFailure() : super('Could not create account');
}

final class AccountNotFoundFailure extends DomainFailure {
  const AccountNotFoundFailure() : super('Account not found');
}

final class NotAuthenticatedFailure extends DomainFailure {
  const NotAuthenticatedFailure() : super('You are not signed in');
}

final class IncorrectPasswordFailure extends DomainFailure {
  const IncorrectPasswordFailure() : super('Current password is incorrect');
}

final class PasswordUnchangedFailure extends DomainFailure {
  const PasswordUnchangedFailure()
      : super('New password must differ from the current one');
}

final class InsufficientFundsFailure extends DomainFailure {
  const InsufficientFundsFailure(super.message);
}

final class EmptyOrderFailure extends DomainFailure {
  const EmptyOrderFailure() : super('Cannot place an empty order');
}

final class MealNotFoundFailure extends DomainFailure {
  const MealNotFoundFailure() : super('Meal not found');
}

final class CartConflictFailure extends DomainFailure {
  const CartConflictFailure()
      : super('Your cart already contains items from another restaurant');
}

final class RemoteLookupFailure extends DomainFailure {
  const RemoteLookupFailure(super.message);
}

final class PersistenceFailure extends DomainFailure {
  const PersistenceFailure(super.message);
}

final class ConfigurationFailure extends DomainFailure {
  const ConfigurationFailure(super.message);
}

final class SuggestionFailure extends DomainFailure {
  const SuggestionFailure(super.message);
}
