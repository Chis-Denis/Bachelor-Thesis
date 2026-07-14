import '../../domain/ordering/order_repository.dart';
import '../../domain/shared/failures.dart';
import '../auth/session_store.dart';
import '../shared/operation_result.dart';
import 'order_dto.dart';

class ListOrders {
  final OrderRepository _repository;
  final SessionStore _session;

  const ListOrders(this._repository, this._session);

  Future<OperationResult<List<OrderDto>>> call() async {
    try {
      final userId = _session.userId;
      if (userId == null) return const OperationResult.ok([]);
      final orders = await _repository.findByUser(userId);
      return OperationResult.ok(
        orders.map(OrderDto.fromDomain).toList(growable: false),
      );
    } on DomainFailure catch (failure) {
      return OperationResult.fail(failure.message);
    } catch (_) {
      return const OperationResult.fail('Could not load orders');
    }
  }
}
