import '../../domain/constants/preferences_constants.dart';
import '../../domain/preferences/dietary_restriction.dart';
import '../../domain/preferences/food_allergy.dart';
import '../../domain/preferences/health_goal.dart';
import '../../domain/preferences/meal_preferences.dart';

class MealPreferencesDto {
  final Set<DietaryRestriction> dietaryRestrictions;
  final Set<FoodAllergy> allergies;
  final HealthGoal? healthGoal;
  final int? dailyCalorieTarget;
  final int mealsPerDay;

  const MealPreferencesDto({
    required this.dietaryRestrictions,
    required this.allergies,
    this.healthGoal,
    this.dailyCalorieTarget,
    required this.mealsPerDay,
  });

  factory MealPreferencesDto.from(MealPreferences preferences) =>
      MealPreferencesDto(
        dietaryRestrictions: preferences.dietaryRestrictions,
        allergies: preferences.allergies,
        healthGoal: preferences.healthGoal,
        dailyCalorieTarget: preferences.dailyCalorieTarget,
        mealsPerDay: preferences.mealsPerDay,
      );

  static MealPreferencesDto get empty => const MealPreferencesDto(
        dietaryRestrictions: {},
        allergies: {},
        mealsPerDay: PreferencesConstants.defaultMealsPerDay,
      );
}
