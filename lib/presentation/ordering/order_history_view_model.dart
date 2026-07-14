import '../../application/ordering/list_orders.dart';
import '../../application/ordering/order_dto.dart';
import '../common/view_model.dart';

class OrderHistoryViewModel extends ViewModel {
  final ListOrders _listOrders;

  bool isLoading = true;
  String? errorMessage;
  List<OrderDto> orders = const [];

  OrderHistoryViewModel(this._listOrders);

  Future<void> load() async {
    isLoading = true;
    notify();
    final result = await _listOrders();
    isLoading = false;
    if (result.isSuccess) {
      orders = result.data ?? const [];
    } else {
      orders = const [];
      errorMessage = result.error;
    }
    notify();
  }

  void clearError() => errorMessage = null;
}
