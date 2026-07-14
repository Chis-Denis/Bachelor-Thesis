import '../../domain/meals/meal_draft.dart';
import '../../domain/shared/macros.dart';
import '../../domain/shared/quantity.dart';
import 'meal_input.dart';

class MealDraftFactory {
  MealDraftFactory._();

  static MealDraft fromInput(MealInput input) => MealDraft(
        name: input.name,
        type: input.type.toDomain(),
        quantity: Quantity(input.quantity),
        unit: input.unit,
        macros: Macros.checked(
          calories: input.macros.calories,
          protein: input.macros.protein,
          carbs: input.macros.carbs,
          fat: input.macros.fat,
          fiber: input.macros.fiber,
          sugar: input.macros.sugar,
        ),
        date: input.date ?? DateTime.now(),
        notes: input.notes,
      );
}
