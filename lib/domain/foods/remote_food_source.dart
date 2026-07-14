import 'food.dart';

abstract interface class RemoteFoodSource {
  Future<List<Food>> search(String query);
}
