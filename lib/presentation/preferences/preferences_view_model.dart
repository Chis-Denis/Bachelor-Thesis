import '../../application/preferences/get_meal_preferences.dart';
import '../../application/preferences/meal_preferences_dto.dart';
import '../../application/preferences/save_meal_preferences.dart';
import '../../domain/constants/preferences_constants.dart';
import '../../domain/preferences/dietary_restriction.dart';
import '../../domain/preferences/food_allergy.dart';
import '../../domain/preferences/health_goal.dart';
import '../common/view_model.dart';

class PreferencesViewModel extends ViewModel {
  final GetMealPreferences _get;
  final SaveMealPreferences _save;
  final int _userId;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Set<DietaryRestriction> dietaryRestrictions = {};
  Set<FoodAllergy> allergies = {};
  HealthGoal? healthGoal;
  int? dailyCalorieTarget;
  int mealsPerDay = PreferencesConstants.defaultMealsPerDay;

  PreferencesViewModel(this._get, this._save, this._userId) {
    _load();
  }

  Future<void> _load() async {
    final dto = await _get(_userId);
    if (dto != null) {
      dietaryRestrictions = dto.dietaryRestrictions.toSet();
      allergies = dto.allergies.toSet();
      healthGoal = dto.healthGoal;
      dailyCalorieTarget = dto.dailyCalorieTarget;
      mealsPerDay = dto.mealsPerDay;
    }
    isLoading = false;
    notify();
  }

  void toggleDietaryRestriction(DietaryRestriction restriction) {
    if (dietaryRestrictions.contains(restriction)) {
      dietaryRestrictions = {...dietaryRestrictions}..remove(restriction);
    } else {
      dietaryRestrictions = {...dietaryRestrictions, restriction};
    }
    notify();
  }

  void toggleAllergy(FoodAllergy allergy) {
    if (allergies.contains(allergy)) {
      allergies = {...allergies}..remove(allergy);
    } else {
      allergies = {...allergies, allergy};
    }
    notify();
  }

  void selectHealthGoal(HealthGoal? goal) {
    healthGoal = goal;
    notify();
  }

  void setCalorieTarget(int? target) {
    dailyCalorieTarget = target;
    notify();
  }

  void setMealsPerDay(int count) {
    mealsPerDay = count.clamp(
      PreferencesConstants.minMealsPerDay,
      PreferencesConstants.maxMealsPerDay,
    );
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
      MealPreferencesDto(
        dietaryRestrictions: dietaryRestrictions,
        allergies: allergies,
        healthGoal: healthGoal,
        dailyCalorieTarget: dailyCalorieTarget,
        mealsPerDay: mealsPerDay,
      ),
    );

    isSaving = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }

  Future<bool> saveDefaults() async {
    dietaryRestrictions = {};
    allergies = {};
    healthGoal = null;
    dailyCalorieTarget = null;
    mealsPerDay = PreferencesConstants.defaultMealsPerDay;
    notify();
    return save();
  }
}
