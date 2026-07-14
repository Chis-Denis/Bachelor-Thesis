import '../constants/validation_constants.dart';
import '../shared/failures.dart';

class Username {
  final String value;

  const Username._(this.value);

  static final RegExp _allowed = RegExp(r'^[A-Za-z0-9_]+$');

  factory Username(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Username is required');
    }
    if (trimmed.length < ValidationConstants.usernameMinLength) {
      throw const ValidationFailure(
        'Username must be at least '
        '${ValidationConstants.usernameMinLength} characters',
      );
    }
    if (trimmed.length > ValidationConstants.usernameMaxLength) {
      throw const ValidationFailure(
        'Username must be at most '
        '${ValidationConstants.usernameMaxLength} characters',
      );
    }
    if (!_allowed.hasMatch(trimmed)) {
      throw const ValidationFailure(
        'Username may contain letters, digits and underscore only',
      );
    }
    return Username._(trimmed);
  }

  @override
  bool operator ==(Object other) => other is Username && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
