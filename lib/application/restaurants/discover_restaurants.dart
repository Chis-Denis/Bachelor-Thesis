import '../../domain/restaurants/restaurant_repository.dart';
import '../../domain/restaurants/restaurant_search_service.dart';
import '../../domain/shared/failures.dart';
import '../shared/operation_result.dart';
import 'restaurant_dto.dart';
import 'restaurant_match_dto.dart';

class DiscoverRestaurants {
  final RestaurantRepository _repository;
  final RestaurantSearchService _search;

  const DiscoverRestaurants(this._repository, this._search);

  Future<OperationResult<List<RestaurantMatchDto>>> call(String query) async {
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        final all = await _repository.findAll();
        return OperationResult.ok([
          for (final restaurant in all)
            RestaurantMatchDto(
              restaurant: RestaurantDto.fromDomain(restaurant),
              matchedItems: const [],
            ),
        ]);
      }
      final matches = await _repository.findMatching(trimmed);
      final ranked = _search.rank(matches, trimmed);
      return OperationResult.ok(
        ranked.map(RestaurantMatchDto.fromDomain).toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load restaurants');
    }
  }
}
