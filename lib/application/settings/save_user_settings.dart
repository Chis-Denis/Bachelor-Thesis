import '../../domain/settings/settings_repository.dart';
import '../../domain/settings/user_settings.dart';
import '../shared/operation_result.dart';
import 'user_settings_dto.dart';

class SaveUserSettings {
  final SettingsRepository _repository;

  const SaveUserSettings(this._repository);

  Future<OperationResult<void>> call(int userId, UserSettingsDto dto) async {
    try {
      await _repository.save(UserSettings(
        userId: userId,
        defaultUnit: dto.defaultUnit,
      ));
      return const OperationResult.ok();
    } catch (_) {
      return const OperationResult.fail('Could not save settings');
    }
  }
}
