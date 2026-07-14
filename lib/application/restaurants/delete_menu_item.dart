import '../../domain/restaurants/restaurant_repository.dart';
import '../shared/operation_result.dart';

class DeleteMenuItem {
  final RestaurantRepository _repository;

  const DeleteMenuItem(this._repository);

  Future<OperationResult<void>> call(int menuItemId) async {
    try {
      await _repository.deleteMenuItem(menuItemId);
      return const OperationResult.ok();
    } catch (_) {
      return const OperationResult.fail('Could not delete item');
    }
  }
}
