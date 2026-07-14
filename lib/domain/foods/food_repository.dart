import 'food.dart';

abstract interface class FoodRepository {
  Future<List<Food>> searchLocal({required int userId, required String query});

  Future<void> upsert({required int userId, required Food food});
}
