import '../../domain/restaurants/menu_item.dart';
import '../../domain/restaurants/menu_item_draft.dart';
import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/failures.dart';
import '../../domain/shared/money.dart';
import '../shared/operation_result.dart';
import 'menu_item_form_dto.dart';

class AddMenuItem {
  final RestaurantRepository _repository;

  const AddMenuItem(this._repository);

  Future<OperationResult<void>> call(
    int restaurantId,
    MenuItemFormDto form,
  ) async {
    try {
      if (form.name.trim().isEmpty) {
        throw const ValidationFailure('Item name is required');
      }
      await _repository.addMenuItem(MenuItemDraft(
        restaurantId: restaurantId,
        name: form.name.trim(),
        description: form.description.trim(),
        category: form.category.trim().isEmpty
            ? MenuItem.defaultCategory
            : form.category.trim(),
        price: Money(form.price),
        macros: form.macros.toDomain(),
      ));
      return const OperationResult.ok();
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not add item');
    }
  }
}
