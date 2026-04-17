import 'package:flutter/foundation.dart';

import '../../../exceptions/app_exception.dart';
import '../entities/user.dart';
import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isSubmitting = false;
  String? _errorMessage;

  AuthController(this._repository) {
    _repository.currentUserListenable.addListener(_onUserChanged);
  }

  User? get currentUser => _repository.currentUser;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> register({
    required String username,
    required String password,
  }) {
    return _run(() => _repository.register(
          username: username,
          password: password,
        ));
  }

  Future<bool> login({
    required String username,
    required String password,
  }) {
    return _run(() => _repository.login(
          username: username,
          password: password,
        ));
  }

  Future<void> logout() => _repository.logout();

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _run(() => _repository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _onUserChanged() => notifyListeners();

  @override
  void dispose() {
    _repository.currentUserListenable.removeListener(_onUserChanged);
    super.dispose();
  }
}
