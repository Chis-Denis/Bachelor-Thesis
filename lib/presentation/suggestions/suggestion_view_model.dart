import '../../application/suggestions/meal_suggestion_dto.dart';
import '../../application/suggestions/suggest_meals.dart';
import '../common/view_model.dart';

class SuggestionViewModel extends ViewModel {
  final SuggestMeals _suggestMeals;

  bool isLoading = false;
  String? errorMessage;
  List<MealSuggestionDto> suggestions = const [];

  SuggestionViewModel(this._suggestMeals);

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    suggestions = const [];
    notify();

    final result = await _suggestMeals();
    if (result.isSuccess) {
      suggestions = result.data ?? const [];
    } else {
      errorMessage = result.error;
    }
    isLoading = false;
    notify();
  }
}
