import '../../application/settings/get_user_settings.dart';
import '../../application/settings/save_user_settings.dart';
import '../../application/settings/user_settings_dto.dart';
import '../../domain/settings/food_unit.dart';
import '../common/view_model.dart';

class SettingsViewModel extends ViewModel {
  final GetUserSettings _get;
  final SaveUserSettings _save;
  final int _userId;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  FoodUnit defaultUnit = FoodUnit.grams;

  SettingsViewModel(this._get, this._save, this._userId) {
    _load();
  }

  Future<void> _load() async {
    final dto = await _get(_userId);
    defaultUnit = dto.defaultUnit;
    isLoading = false;
    notify();
  }

  void selectDefaultUnit(FoodUnit unit) {
    defaultUnit = unit;
    notify();
  }

  void clearError() {
    errorMessage = null;
    notify();
  }

  Future<bool> save() async {
    isSaving = true;
    errorMessage = null;
    notify();

    final result = await _save(
      _userId,
      UserSettingsDto(defaultUnit: defaultUnit),
    );

    isSaving = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }
}
