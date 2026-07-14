import 'new_order.dart';
import 'order.dart';

abstract interface class OrderRepository {
  Future<int> create({required int userId, required NewOrder order});

  Future<List<Order>> findByUser(int userId);
}
