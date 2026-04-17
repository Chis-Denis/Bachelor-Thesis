import 'package:flutter/foundation.dart';

import '../../../database/database.dart';
import '../../../exceptions/app_exception.dart';
import '../../../utils/money_formatter.dart';
import '../../auth/services/auth_repository.dart';
import '../entities/order.dart';

class OrderRepository {
  final AppDatabase _database;
  final AuthRepository _authRepository;

  final ValueNotifier<int> _ordersChanged = ValueNotifier<int>(0);

  OrderRepository(this._database, this._authRepository);

  ValueListenable<int> get ordersChanged => _ordersChanged;

  Future<Order> placeOrder({
    required int? restaurantId,
    required String restaurantName,
    required double deliveryFee,
    required List<OrderLineItem> items,
  }) async {
    if (items.isEmpty) {
      throw const AppException('Cannot place an empty order');
    }
    final user = _authRepository.currentUser;
    if (user == null) {
      throw const AppException('You must be signed in to place an order');
    }

    final subtotal = items.fold<double>(
      0,
      (sum, i) => sum + i.price * i.quantity,
    );
    final total = subtotal + deliveryFee;

    if (user.balance < total) {
      throw AppException(
        'Not enough funds. You have ${formatLei(user.balance)} but '
        'need ${formatLei(total)}.',
      );
    }

    final db = await _database.open();
    final now = DateTime.now();

    final orderId = await db.transaction<int>((txn) async {
      final id = await txn.insert(OrdersTable.name, {
        OrdersTable.userId: user.id,
        OrdersTable.restaurantId: restaurantId,
        OrdersTable.restaurantName: restaurantName,
        OrdersTable.subtotal: subtotal,
        OrdersTable.deliveryFee: deliveryFee,
        OrdersTable.total: total,
        OrdersTable.createdAt: now.millisecondsSinceEpoch,
      });

      for (final item in items) {
        await txn.insert(OrderItemsTable.name, {
          OrderItemsTable.orderId: id,
          OrderItemsTable.menuItemId: item.menuItemId,
          OrderItemsTable.itemName: item.name,
          OrderItemsTable.description: item.description,
          OrderItemsTable.price: item.price,
          OrderItemsTable.quantity: item.quantity,
          OrderItemsTable.calories: item.calories,
          OrderItemsTable.protein: item.protein,
          OrderItemsTable.carbs: item.carbs,
          OrderItemsTable.fat: item.fat,
          OrderItemsTable.fiber: item.fiber,
          OrderItemsTable.sugar: item.sugar,
        });
      }

      return id;
    });

    await _authRepository.adjustBalance(-total);
    _ordersChanged.value = _ordersChanged.value + 1;

    return Order(
      id: orderId,
      userId: user.id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      createdAt: now,
      items: items,
    );
  }

  Future<List<Order>> findByCurrentUser() async {
    final user = _authRepository.currentUser;
    if (user == null) return const [];
    return findByUser(user.id);
  }

  Future<List<Order>> findByUser(int userId) async {
    final db = await _database.open();
    final orderRows = await db.query(
      OrdersTable.name,
      where: '${OrdersTable.userId} = ?',
      whereArgs: [userId],
      orderBy: '${OrdersTable.createdAt} DESC',
    );
    if (orderRows.isEmpty) return const [];

    final orderIds = orderRows
        .map((r) => (r[OrdersTable.id] as num).toInt())
        .toList(growable: false);

    final placeholders = List.filled(orderIds.length, '?').join(',');
    final itemRows = await db.query(
      OrderItemsTable.name,
      where: '${OrderItemsTable.orderId} IN ($placeholders)',
      whereArgs: orderIds,
      orderBy: '${OrderItemsTable.id} ASC',
    );

    final itemsByOrder = <int, List<OrderLineItem>>{};
    for (final row in itemRows) {
      final orderId = (row[OrderItemsTable.orderId] as num).toInt();
      itemsByOrder.putIfAbsent(orderId, () => <OrderLineItem>[]).add(
            _itemFromRow(row),
          );
    }

    return orderRows
        .map((row) => _orderFromRow(
              row,
              itemsByOrder[(row[OrdersTable.id] as num).toInt()] ?? const [],
            ))
        .toList(growable: false);
  }

  Order _orderFromRow(
    Map<String, Object?> row,
    List<OrderLineItem> items,
  ) {
    return Order(
      id: (row[OrdersTable.id] as num).toInt(),
      userId: (row[OrdersTable.userId] as num).toInt(),
      restaurantId: (row[OrdersTable.restaurantId] as num?)?.toInt(),
      restaurantName: row[OrdersTable.restaurantName] as String,
      subtotal: (row[OrdersTable.subtotal] as num?)?.toDouble() ?? 0,
      deliveryFee: (row[OrdersTable.deliveryFee] as num?)?.toDouble() ?? 0,
      total: (row[OrdersTable.total] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row[OrdersTable.createdAt] as int,
      ),
      items: items,
    );
  }

  OrderLineItem _itemFromRow(Map<String, Object?> row) {
    return OrderLineItem(
      id: (row[OrderItemsTable.id] as num?)?.toInt(),
      menuItemId: (row[OrderItemsTable.menuItemId] as num?)?.toInt(),
      name: row[OrderItemsTable.itemName] as String,
      description: (row[OrderItemsTable.description] as String?) ?? '',
      price: (row[OrderItemsTable.price] as num).toDouble(),
      quantity: (row[OrderItemsTable.quantity] as num?)?.toDouble() ?? 1,
      calories: (row[OrderItemsTable.calories] as num?)?.toDouble() ?? 0,
      protein: (row[OrderItemsTable.protein] as num?)?.toDouble() ?? 0,
      carbs: (row[OrderItemsTable.carbs] as num?)?.toDouble() ?? 0,
      fat: (row[OrderItemsTable.fat] as num?)?.toDouble() ?? 0,
      fiber: (row[OrderItemsTable.fiber] as num?)?.toDouble() ?? 0,
      sugar: (row[OrderItemsTable.sugar] as num?)?.toDouble() ?? 0,
    );
  }
}
