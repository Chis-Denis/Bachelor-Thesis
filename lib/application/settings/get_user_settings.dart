import '../../domain/settings/settings_repository.dart';
import 'user_settings_dto.dart';

class GetUserSettings {
  final SettingsRepository _repository;

  const GetUserSettings(this._repository);

  Future<UserSettingsDto> call(int userId) async {
    final settings = await _repository.findByUserId(userId);
    return settings == null
        ? UserSettingsDto.defaults
        : UserSettingsDto.from(settings);
  }
}
