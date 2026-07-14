import 'food_dto.dart';

class FoodSearchResultDto {
  final List<FoodDto> foods;
  final String? remoteError;

  const FoodSearchResultDto({required this.foods, this.remoteError});
}
