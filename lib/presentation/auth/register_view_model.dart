import '../../application/auth/register_user.dart';
import '../common/view_model.dart';

class RegisterViewModel extends ViewModel {
  final RegisterUser _registerUser;

  bool isSubmitting = false;
  String? errorMessage;

  RegisterViewModel(this._registerUser);

  Future<int?> register(
    String username,
    String password, {
    bool isBusinessOwner = false,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notify();
    final result = await _registerUser(
      username,
      password,
      isBusinessOwner: isBusinessOwner,
    );
    if (!result.isSuccess) errorMessage = result.error;
    isSubmitting = false;
    notify();
    return result.data;
  }

  void clearError() => errorMessage = null;
}
