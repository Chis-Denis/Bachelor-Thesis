import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../utils/money_formatter.dart';
import '../../meals/screens/date_format.dart';
import '../entities/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  List<Order> _orders = const [];

  @override
  void initState() {
    super.initState();
    orderRepository.ordersChanged.addListener(_onOrdersChanged);
    _load();
  }

  @override
  void dispose() {
    orderRepository.ordersChanged.removeListener(_onOrdersChanged);
    super.dispose();
  }

  void _onOrdersChanged() => _load();

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final orders = await orderRepository.findByCurrentUser();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _orders = const [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Order history',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No orders yet',
                style: AppTypography.subheading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Place an order from the Foods screen and it will show up here.',
                style: AppTypography.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _OrderCard(order: _orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: AppTypography.subheading.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDateRelative(order.createdAt)} · '
                      '${formatTime(order.createdAt)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatLei(order.total),
                style: AppTypography.subheading.copyWith(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          ...order.items.map((item) => _OrderLine(item: item)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          _Summary(order: order),
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  final OrderLineItem item;

  const _OrderLine({required this.item});

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${qty}x',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: AppTypography.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(_macroLine(), style: AppTypography.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                formatLei(item.lineTotal),
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _macroLine() {
    final qty = item.quantity;
    final cals = (item.calories * qty).round();
    final p = (item.protein * qty).round();
    final c = (item.carbs * qty).round();
    final f = (item.fat * qty).round();
    return '$cals kcal · P ${p}g · C ${c}g · F ${f}g';
  }
}

class _Summary extends StatelessWidget {
  final Order order;

  const _Summary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Subtotal', formatLei(order.subtotal)),
        const SizedBox(height: 4),
        _row('Delivery', formatLei(order.deliveryFee)),
        const SizedBox(height: 4),
        _row(
          'Total',
          formatLei(order.total),
          isBold: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        _row(
          'Calories',
          '${order.totalCalories.round()} kcal',
          muted: true,
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isBold = false, bool muted = false}) {
    final style = muted
        ? AppTypography.caption
        : AppTypography.body.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
