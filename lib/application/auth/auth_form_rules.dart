import '../../domain/constants/validation_constants.dart';

class AuthFormRules {
  AuthFormRules._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  static String? username(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Required';
    if (trimmed.length < ValidationConstants.usernameMinLength) {
      return 'At least ${ValidationConstants.usernameMinLength} characters';
    }
    if (trimmed.length > ValidationConstants.usernameMaxLength) {
      return 'At most ${ValidationConstants.usernameMaxLength} characters';
    }
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(trimmed)) {
      return 'Letters, digits and underscore only';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < ValidationConstants.passwordMinLength) {
      return 'At least ${ValidationConstants.passwordMinLength} characters';
    }
    return null;
  }
}
