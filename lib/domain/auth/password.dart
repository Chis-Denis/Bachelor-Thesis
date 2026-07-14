import '../constants/validation_constants.dart';
import '../shared/failures.dart';

class Password {
  final String value;

  const Password._(this.value);

  factory Password(String raw) {
    if (raw.isEmpty) {
      throw const ValidationFailure('Password is required');
    }
    if (raw.length < ValidationConstants.passwordMinLength) {
      throw const ValidationFailure(
        'Password must be at least '
        '${ValidationConstants.passwordMinLength} characters',
      );
    }
    return Password._(raw);
  }
}
