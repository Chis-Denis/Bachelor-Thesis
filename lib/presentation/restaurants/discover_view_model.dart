import '../../application/restaurants/discover_restaurants.dart';
import '../../application/restaurants/restaurant_match_dto.dart';
import '../common/view_model.dart';

class DiscoverViewModel extends ViewModel {
  final DiscoverRestaurants _discover;

  bool isLoading = true;
  String activeQuery = '';
  String? errorMessage;
  List<RestaurantMatchDto> results = const [];

  int _requestId = 0;

  DiscoverViewModel(this._discover);

  Future<void> search(String value) async {
    final requestId = ++_requestId;
    isLoading = true;
    activeQuery = value.trim();
    notify();

    final result = await _discover(value);
    if (requestId != _requestId) return;
    isLoading = false;
    if (result.isSuccess) {
      results = result.data ?? const [];
    } else {
      results = const [];
      errorMessage = result.error;
    }
    notify();
  }

  void clearError() => errorMessage = null;
}
