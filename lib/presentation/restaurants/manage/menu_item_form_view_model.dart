import '../../../application/restaurants/add_menu_item.dart';
import '../../../application/restaurants/menu_item_form_dto.dart';
import '../../../application/restaurants/update_menu_item.dart';
import '../../common/view_model.dart';

class MenuItemFormViewModel extends ViewModel {
  final AddMenuItem _add;
  final UpdateMenuItem _update;

  bool isSaving = false;
  String? errorMessage;

  MenuItemFormViewModel(this._add, this._update);

  Future<bool> submit({
    required int restaurantId,
    int? menuItemId,
    required MenuItemFormDto form,
  }) async {
    isSaving = true;
    errorMessage = null;
    notify();
    final result = menuItemId == null
        ? await _add(restaurantId, form)
        : await _update(menuItemId, restaurantId, form);
    isSaving = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
