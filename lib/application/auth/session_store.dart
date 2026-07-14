import '../shared/observable_value.dart';
import 'user_dto.dart';

class SessionStore {
  final ObservableValue<UserDto?> _user = ObservableValue<UserDto?>(null);

  ObservableValue<UserDto?> get user => _user;

  UserDto? get current => _user.value;

  int? get userId => _user.value?.id;

  void set(UserDto user) => _user.value = user;

  void clear() => _user.value = null;

  void dispose() => _user.dispose();
}
