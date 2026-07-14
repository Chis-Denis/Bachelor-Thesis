import '../../application/foods/food_dto.dart';
import '../../application/foods/search_foods.dart';
import '../common/view_model.dart';

class FoodSearchViewModel extends ViewModel {
  final SearchFoods _searchFoods;

  bool isLoading = false;
  bool hasSearched = false;
  String? remoteError;
  List<FoodDto> results = const [];

  int _requestId = 0;

  FoodSearchViewModel(this._searchFoods);

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      isLoading = false;
      hasSearched = false;
      results = const [];
      remoteError = null;
      notify();
      return;
    }
    final requestId = ++_requestId;
    isLoading = true;
    hasSearched = true;
    notify();

    final result = await _searchFoods(trimmed);
    if (requestId != _requestId) return;
    isLoading = false;
    results = result.foods;
    remoteError = result.remoteError;
    notify();
  }
}
