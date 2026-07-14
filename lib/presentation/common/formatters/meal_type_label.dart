import 'package:flutter/material.dart';

import '../../../application/meals/meal_type_view.dart';
import '../../design/design.dart';

class MealTypeLabel {
  MealTypeLabel._();

  static String text(MealTypeView type) {
    switch (type) {
      case MealTypeView.breakfast:
        return 'Breakfast';
      case MealTypeView.lunch:
        return 'Lunch';
      case MealTypeView.dinner:
        return 'Dinner';
      case MealTypeView.snack:
        return 'Snack';
    }
  }

  static Color color(MealTypeView type) {
    switch (type) {
      case MealTypeView.breakfast:
        return AppColors.mealBreakfast;
      case MealTypeView.lunch:
        return AppColors.mealLunch;
      case MealTypeView.dinner:
        return AppColors.mealDinner;
      case MealTypeView.snack:
        return AppColors.mealSnack;
    }
  }
}
