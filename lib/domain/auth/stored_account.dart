import '../shared/hashed_password.dart';
import 'user.dart';

class StoredAccount {
  final User user;
  final HashedPassword credential;

  const StoredAccount({required this.user, required this.credential});
}
