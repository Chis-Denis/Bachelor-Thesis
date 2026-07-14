import '../../domain/ordering/new_order.dart';
import '../../domain/ordering/order.dart';
import '../../domain/ordering/order_repository.dart';
import '../../domain/shared/money.dart';
import '../persistence/macros_row.dart';
import '../persistence/sqflite_unit_of_work.dart';
import '../persistence/tables.dart';

class SqfliteOrderRepository implements OrderRepository {
  final SqfliteUnitOfWork _work;

  SqfliteOrderRepository(this._work);

  @override
  Future<int> create({required int userId, required NewOrder order}) async {
    final db = await _work.executor();
    final orderId = await db.insert(OrdersTable.name, {
      OrdersTable.userId: userId,
      OrdersTable.restaurantId: order.restaurantId,
      OrdersTable.restaurantName: order.restaurantName,
      OrdersTable.subtotal: order.subtotal.amount,
      OrdersTable.deliveryFee: order.deliveryFee.amount,
      OrdersTable.total: order.total.amount,
      OrdersTable.createdAt: order.createdAt.millisecondsSinceEpoch,
    });
    for (final line in order.lines) {
      await db.insert(OrderItemsTable.name, {
        OrderItemsTable.orderId: orderId,
        OrderItemsTable.menuItemId: line.menuItemId,
        OrderItemsTable.itemName: line.name,
        OrderItemsTable.description: line.description,
        OrderItemsTable.price: line.price.amount,
        OrderItemsTable.quantity: line.quantity,
        ...MacrosRow.toColumns(line.macros, TableMacros.orderItems),
      });
    }
    return orderId;
  }

  @override
  Future<List<Order>> findByUser(int userId) async {
    final db = await _work.executor();
    final orderRows = await db.query(
      OrdersTable.name,
      where: '${OrdersTable.userId} = ?',
      whereArgs: [userId],
      orderBy: '${OrdersTable.createdAt} DESC',
    );
    if (orderRows.isEmpty) return const [];

    final orderIds = orderRows
        .map((row) => (row[OrdersTable.id] as num).toInt())
        .toList(growable: false);
    final placeholders = List.filled(orderIds.length, '?').join(',');
    final itemRows = await db.query(
      OrderItemsTable.name,
      where: '${OrderItemsTable.orderId} IN ($placeholders)',
      whereArgs: orderIds,
      orderBy: '${OrderItemsTable.id} ASC',
    );

    final linesByOrder = <int, List<OrderLine>>{};
    for (final row in itemRows) {
      final orderId = (row[OrderItemsTable.orderId] as num).toInt();
      linesByOrder
          .putIfAbsent(orderId, () => <OrderLine>[])
          .add(_lineFromRow(row));
    }

    return orderRows
        .map((row) => _orderFromRow(
              row,
              linesByOrder[(row[OrdersTable.id] as num).toInt()] ?? const [],
            ))
        .toList(growable: false);
  }

  Order _orderFromRow(Map<String, Object?> row, List<OrderLine> lines) => Order(
        id: (row[OrdersTable.id] as num).toInt(),
        userId: (row[OrdersTable.userId] as num).toInt(),
        restaurantId: (row[OrdersTable.restaurantId] as num?)?.toInt(),
        restaurantName: row[OrdersTable.restaurantName] as String,
        subtotal: Money((row[OrdersTable.subtotal] as num?)?.toDouble() ?? 0),
        deliveryFee:
            Money((row[OrdersTable.deliveryFee] as num?)?.toDouble() ?? 0),
        total: Money((row[OrdersTable.total] as num?)?.toDouble() ?? 0),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            row[OrdersTable.createdAt] as int),
        lines: lines,
      );

  OrderLine _lineFromRow(Map<String, Object?> row) => OrderLine(
        id: (row[OrderItemsTable.id] as num?)?.toInt(),
        menuItemId: (row[OrderItemsTable.menuItemId] as num?)?.toInt(),
        name: row[OrderItemsTable.itemName] as String,
        description: (row[OrderItemsTable.description] as String?) ?? '',
        price: Money((row[OrderItemsTable.price] as num).toDouble()),
        quantity: (row[OrderItemsTable.quantity] as num?)?.toDouble() ?? 1,
        macros: MacrosRow.read(row, TableMacros.orderItems),
      );
}
