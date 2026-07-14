import '../../application/auth/login_user.dart';
import '../../application/meals/load_meals.dart';
import '../common/view_model.dart';

class LoginViewModel extends ViewModel {
  final LoginUser _loginUser;
  final LoadMeals _loadMeals;

  bool isSubmitting = false;
  String? errorMessage;

  LoginViewModel(this._loginUser, this._loadMeals);

  Future<bool> login(String username, String password) async {
    isSubmitting = true;
    errorMessage = null;
    notify();
    final result = await _loginUser(username, password);
    if (result.isSuccess) {
      await _loadMeals();
    } else {
      errorMessage = result.error;
    }
    isSubmitting = false;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
