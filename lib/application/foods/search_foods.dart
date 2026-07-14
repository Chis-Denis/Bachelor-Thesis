import '../../domain/foods/food.dart';
import '../../domain/foods/food_ranking_service.dart';
import '../../domain/foods/food_repository.dart';
import '../../domain/foods/nutrition_plausibility.dart';
import '../../domain/foods/remote_food_source.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import 'food_dto.dart';
import 'food_search_result_dto.dart';

class SearchFoods {
  final FoodRepository _local;
  final RemoteFoodSource _remote;
  final SessionStore _session;
  final FoodRankingService _ranking;
  final NutritionPlausibility _plausibility;

  const SearchFoods(
    this._local,
    this._remote,
    this._session,
    this._ranking,
    this._plausibility,
  );

  Future<FoodSearchResultDto> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const FoodSearchResultDto(foods: []);
    }

    final userId = _session.userId;
    final local = userId == null
        ? const <Food>[]
        : await _local.searchLocal(userId: userId, query: trimmed);
    final localNames = local.map((food) => food.name.toLowerCase()).toSet();
    final localRanked = _ranking.rank(local, trimmed);

    try {
      final remote = await _remote.search(trimmed);
      final filtered = remote
          .where((food) =>
              _plausibility.isPlausible(food) &&
              !localNames.contains(food.name.toLowerCase()))
          .toList();
      final remoteRanked = _ranking.rank(filtered, trimmed);
      return FoodSearchResultDto(
        foods: [...localRanked, ...remoteRanked]
            .map(FoodDto.fromDomain)
            .toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return FoodSearchResultDto(
        foods: localRanked.map(FoodDto.fromDomain).toList(growable: false),
        remoteError: failure.message,
      );
    } catch (_) {
      return FoodSearchResultDto(
        foods: localRanked.map(FoodDto.fromDomain).toList(growable: false),
        remoteError: 'Lookup failed',
      );
    }
  }
}
