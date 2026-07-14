import '../../domain/preferences/preferences_repository.dart';
import 'meal_preferences_dto.dart';

class GetMealPreferences {
  final PreferencesRepository _repository;

  const GetMealPreferences(this._repository);

  Future<MealPreferencesDto?> call(int userId) async {
    final prefs = await _repository.findByUserId(userId);
    return prefs == null ? null : MealPreferencesDto.from(prefs);
  }
}
