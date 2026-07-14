import 'meal_preferences.dart';

abstract class PreferencesRepository {
  Future<MealPreferences?> findByUserId(int userId);
  Future<void> save(MealPreferences preferences);
}
