import 'meal_suggestion.dart';
import 'suggestion_request.dart';

abstract interface class MealSuggestionRepository {
  Future<List<MealSuggestion>> suggest(SuggestionRequest request);
}
