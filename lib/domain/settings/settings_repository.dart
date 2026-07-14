import 'user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings?> findByUserId(int userId);
  Future<void> save(UserSettings settings);
}
