import '../preferences/dietary_restriction.dart';
import '../preferences/food_allergy.dart';
import '../preferences/health_goal.dart';
import 'eligible_menu_item.dart';

class SuggestionRequest {
  final int userId;

  final Set<FoodAllergy> allergies;
  final Set<DietaryRestriction> dietaryRestrictions;

  final HealthGoal? healthGoal;
  final int? dailyCalorieTarget;
  final int mealsPerDay;

  final double walletBalance;

  final double caloriesConsumedToday;
  final double proteinConsumedToday;
  final double carbsConsumedToday;
  final double fatConsumedToday;

  final List<String> recentMenuItemNames;
  final List<String> recentCuisines;

  final List<EligibleMenuItem> eligibleItems;

  final int recommendationCount;

  const SuggestionRequest({
    required this.userId,
    required this.allergies,
    required this.dietaryRestrictions,
    required this.healthGoal,
    required this.dailyCalorieTarget,
    required this.mealsPerDay,
    required this.walletBalance,
    required this.caloriesConsumedToday,
    required this.proteinConsumedToday,
    required this.carbsConsumedToday,
    required this.fatConsumedToday,
    required this.recentMenuItemNames,
    required this.recentCuisines,
    required this.eligibleItems,
    required this.recommendationCount,
  });

  double? get remainingCalories {
    final target = dailyCalorieTarget;
    if (target == null) return null;
    return target - caloriesConsumedToday;
  }
}
