import '../../application/auth/change_password.dart';
import '../common/view_model.dart';

class ChangePasswordViewModel extends ViewModel {
  final ChangePassword _changePassword;

  bool isSubmitting = false;
  String? errorMessage;

  ChangePasswordViewModel(this._changePassword);

  Future<bool> submit(String currentPassword, String newPassword) async {
    isSubmitting = true;
    errorMessage = null;
    notify();
    final result = await _changePassword(currentPassword, newPassword);
    if (!result.isSuccess) errorMessage = result.error;
    isSubmitting = false;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
