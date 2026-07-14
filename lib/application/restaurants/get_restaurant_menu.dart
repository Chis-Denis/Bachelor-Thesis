import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/shared/failures.dart';
import '../shared/operation_result.dart';
import 'menu_item_dto.dart';

class GetRestaurantMenu {
  final RestaurantRepository _repository;

  const GetRestaurantMenu(this._repository);

  Future<OperationResult<List<MenuItemDto>>> call(int restaurantId) async {
    try {
      final items = await _repository.menuFor(restaurantId);
      return OperationResult.ok(
        items.map(MenuItemDto.fromDomain).toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load menu');
    }
  }
}
