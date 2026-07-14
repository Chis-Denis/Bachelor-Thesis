import '../constants/nutrition_constants.dart';
import 'food.dart';

class NutritionPlausibility {
  const NutritionPlausibility();

  bool isPlausible(Food food) {
    if (food.servingSize <= 0) return false;

    final macros = food.macros;
    final hasMacros = macros.protein > NutritionConstants.presenceEpsilon ||
        macros.carbs > NutritionConstants.presenceEpsilon ||
        macros.fat > NutritionConstants.presenceEpsilon;
    if (macros.calories <= NutritionConstants.presenceEpsilon && hasMacros) {
      return false;
    }

    final estimatedCalories =
        macros.protein * NutritionConstants.caloriesPerGramProtein +
            macros.carbs * NutritionConstants.caloriesPerGramCarbs +
            macros.fat * NutritionConstants.caloriesPerGramFat;
    if ((macros.calories - estimatedCalories).abs() >
        NutritionConstants.calorieMacroTolerance) {
      return false;
    }

    final unit = food.servingUnit.toLowerCase();
    if (unit == 'g' || unit == 'ml') {
      final density = macros.calories / food.servingSize;
      if (density > NutritionConstants.maxCaloriesPerGram) return false;
    }
    return true;
  }
}
