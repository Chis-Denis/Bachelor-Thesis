import 'package:flutter/material.dart';

import '../../application/ordering/order_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/date_format.dart';
import '../common/formatters/money_format.dart';
import '../common/formatters/number_format.dart';
import '../design/design.dart';
import '../issues/report_issue_screen.dart';
import 'order_history_view_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final OrderHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderHistoryViewModel(AppScope.of(context).listOrders)
      ..addListener(_onChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final error = _viewModel.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      _viewModel.clearError();
    }
    setState(() {});
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
    if (_viewModel.isLoading && _viewModel.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
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
      onRefresh: _viewModel.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        itemCount: _viewModel.orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _OrderCard(order: _viewModel.orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderDto order;

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
          ...order.lines.map((line) => _OrderLine(line: line)),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          _Summary(order: order),
          if (order.restaurantId != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: const Text('Report a problem'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReportIssueScreen(
                      restaurantId: order.restaurantId!,
                      orderId: order.id,
                      restaurantName: order.restaurantName,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  final OrderLineDto line;

  const _OrderLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final quantity = Numbers.serving(line.quantity);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${quantity}x',
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
                  line.name,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                ),
                if (line.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line.description,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${line.macros.calories.round()} kcal · '
                  'P ${line.macros.protein.round()}g · '
                  'C ${line.macros.carbs.round()}g · '
                  'F ${line.macros.fat.round()}g',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatLei(line.lineTotal),
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final OrderDto order;

  const _Summary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Subtotal', formatLei(order.subtotal)),
        const SizedBox(height: 4),
        _row('Delivery', formatLei(order.deliveryFee)),
        const SizedBox(height: 4),
        _row('Total', formatLei(order.total), isBold: true),
        const SizedBox(height: AppSpacing.xs),
        _row('Calories', '${order.totalMacros.calories.round()} kcal',
            muted: true),
      ],
    );
  }

  Widget _row(String label, String value,
      {bool isBold = false, bool muted = false}) {
    final style = muted
        ? AppTypography.caption
        : AppTypography.body
            .copyWith(fontWeight: isBold ? FontWeight.w600 : FontWeight.w400);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
