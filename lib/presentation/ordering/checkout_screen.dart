import 'package:flutter/material.dart';

import '../../application/ordering/cart_dto.dart';
import '../../application/ordering/cart_line_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import 'checkout_view_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = CheckoutViewModel(
      deps.cartService,
      deps.placeOrder,
      deps.session,
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _placeOrder() async {
    final restaurantName = _viewModel.cart.restaurant?.name ?? '';
    final success = await _viewModel.placeOrder();
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not place order';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Order placed with $restaurantName — added to your meals'),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Your order',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      body: _viewModel.cart.isEmpty
          ? const _EmptyCart()
          : _CartContent(
              cart: _viewModel.cart,
              balance: _viewModel.balance,
              canAfford: _viewModel.canAfford,
              isPlacing: _viewModel.isPlacing,
              onIncrement: _viewModel.increment,
              onDecrement: _viewModel.decrement,
              onRemove: _viewModel.remove,
              onPlaceOrder: _placeOrder,
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your cart is empty.',
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartDto cart;
  final double balance;
  final bool canAfford;
  final bool isPlacing;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final ValueChanged<int> onRemove;
  final VoidCallback onPlaceOrder;

  const _CartContent({
    required this.cart,
    required this.balance,
    required this.canAfford,
    required this.isPlacing,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = cart.restaurant;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            children: [
              if (restaurant != null) ...[
                Text(
                  restaurant.name,
                  style: AppTypography.heading.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  '${restaurant.cuisine} · '
                  '${formatLei(restaurant.deliveryFee)} delivery · '
                  '~${restaurant.estimatedMinutes} min',
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              for (final line in cart.lines) ...[
                _CartLineRow(
                  line: line,
                  onIncrement: () => onIncrement(line.menuItemId),
                  onDecrement: () => onDecrement(line.menuItemId),
                  onRemove: () => onRemove(line.menuItemId),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              _SummarySection(
                subtotal: cart.subtotal,
                deliveryFee: cart.deliveryFee,
                total: cart.total,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Wallet: ${formatLei(balance)}',
                  style: AppTypography.caption,
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppRadii.all8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Not enough funds in your wallet.',
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SizedBox(
              height: AppSizes.buttonHeight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textOnDark,
                  disabledBackgroundColor: AppColors.accentDisabled,
                  disabledForegroundColor: AppColors.textOnDark,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.all8,
                  ),
                ),
                onPressed: (canAfford && !isPlacing) ? onPlaceOrder : null,
                child: isPlacing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnDark,
                          ),
                        ),
                      )
                    : Text(
                        canAfford
                            ? 'Order · ${formatLei(cart.total)}'
                            : 'Not enough funds',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartLineRow extends StatelessWidget {
  final CartLineDto line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartLineRow({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${formatLei(line.unitPrice)} each',
                    style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                _QuantityControls(
                  quantity: line.quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatLei(line.lineTotal),
                style: AppTypography.body
                    .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Remove',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControls({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIconButton(icon: Icons.remove, onPressed: onDecrement),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: AppTypography.body
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          _RoundIconButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadii.pill,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const _SummarySection({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.all8,
      ),
      child: Column(
        children: [
          _row('Subtotal', formatLei(subtotal)),
          const SizedBox(height: 6),
          _row('Delivery', formatLei(deliveryFee)),
          const Divider(height: 20),
          _row('Total', formatLei(total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = AppTypography.body.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: bold ? 15 : 14,
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
