import '../../domain/preferences/meal_preferences.dart';
import '../../domain/preferences/preferences_repository.dart';
import '../shared/operation_result.dart';
import 'meal_preferences_dto.dart';

class SaveMealPreferences {
  final PreferencesRepository _repository;

  const SaveMealPreferences(this._repository);

  Future<OperationResult<void>> call(int userId, MealPreferencesDto dto) async {
    try {
      await _repository.save(MealPreferences(
        userId: userId,
        dietaryRestrictions: dto.dietaryRestrictions,
        allergies: dto.allergies,
        healthGoal: dto.healthGoal,
        dailyCalorieTarget: dto.dailyCalorieTarget,
        mealsPerDay: dto.mealsPerDay,
      ));
      return const OperationResult.ok();
    } catch (_) {
      return const OperationResult.fail('Could not save preferences');
    }
  }
}
