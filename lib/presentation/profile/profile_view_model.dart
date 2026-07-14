import '../../application/auth/add_funds.dart';
import '../../application/auth/logout_user.dart';
import '../../application/auth/session_store.dart';
import '../../application/auth/user_dto.dart';
import '../common/view_model.dart';

class ProfileViewModel extends ViewModel {
  final SessionStore _session;
  final LogoutUser _logout;
  final AddFunds _addFunds;

  UserDto? user;
  String? errorMessage;

  ProfileViewModel(this._session, this._logout, this._addFunds)
      : user = _session.current {
    bind(_session.user.changes, (value) {
      user = value;
      notify();
    });
  }

  void logout() => _logout();

  Future<bool> addFunds(double amount) async {
    final result = await _addFunds(amount);
    if (!result.isSuccess) {
      errorMessage = result.error;
      notify();
    }
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
