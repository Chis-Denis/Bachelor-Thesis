import '../constants/preferences_constants.dart';
import 'dietary_restriction.dart';
import 'food_allergy.dart';
import 'health_goal.dart';

class MealPreferences {
  final int userId;
  final Set<DietaryRestriction> dietaryRestrictions;
  final Set<FoodAllergy> allergies;
  final HealthGoal? healthGoal;
  final int? dailyCalorieTarget;
  final int mealsPerDay;

  const MealPreferences({
    required this.userId,
    required this.dietaryRestrictions,
    required this.allergies,
    this.healthGoal,
    this.dailyCalorieTarget,
    required this.mealsPerDay,
  });

  static MealPreferences empty(int userId) => MealPreferences(
        userId: userId,
        dietaryRestrictions: const {},
        allergies: const {},
        mealsPerDay: PreferencesConstants.defaultMealsPerDay,
      );

  bool get hasAnyPreferences =>
      dietaryRestrictions.isNotEmpty ||
      allergies.isNotEmpty ||
      healthGoal != null ||
      dailyCalorieTarget != null;
}
