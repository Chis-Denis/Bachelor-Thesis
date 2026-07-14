import '../../../application/restaurants/restaurant_form_dto.dart';
import '../../../application/restaurants/save_my_restaurant.dart';
import '../../common/view_model.dart';

class RestaurantFormViewModel extends ViewModel {
  final SaveMyRestaurant _save;

  bool isSaving = false;
  String? errorMessage;

  RestaurantFormViewModel(this._save);

  Future<bool> save(RestaurantFormDto form) async {
    isSaving = true;
    errorMessage = null;
    notify();
    final result = await _save(form);
    isSaving = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
