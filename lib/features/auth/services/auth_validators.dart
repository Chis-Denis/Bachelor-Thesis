class AuthValidators {
  AuthValidators._();

  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 20;
  static const int passwordMinLength = 8;

  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9_]+$');

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final v = value.trim();
    if (v.length < usernameMinLength) {
      return 'At least $usernameMinLength characters';
    }
    if (v.length > usernameMaxLength) {
      return 'At most $usernameMaxLength characters';
    }
    if (!_usernamePattern.hasMatch(v)) {
      return 'Letters, digits and underscore only';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < passwordMinLength) {
      return 'At least $passwordMinLength characters';
    }
    return null;
  }
}
