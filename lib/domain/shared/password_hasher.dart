import 'hashed_password.dart';

abstract interface class PasswordHasher {
  HashedPassword hash(String rawPassword);

  bool verify(String rawPassword, HashedPassword stored);
}
