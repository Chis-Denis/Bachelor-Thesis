import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../exceptions/app_exception.dart';
import '../../../utils/money_formatter.dart';
import '../../meals/entities/meal_type.dart';
import '../entities/order.dart';
import '../services/cart_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPlacing = false;

  Future<void> _placeOrder() async {
    if (cartController.isEmpty || _isPlacing) return;
    final restaurant = cartController.restaurant;
    if (restaurant == null) return;

    setState(() => _isPlacing = true);
    try {
      final lines = cartController.lines;
      final orderItems = lines
          .map((line) => OrderLineItem(
                menuItemId: line.menuItem.id,
                name: line.menuItem.name,
                description: line.menuItem.description,
                price: line.menuItem.price,
                quantity: line.quantity.toDouble(),
                calories: line.menuItem.calories,
                protein: line.menuItem.protein,
                carbs: line.menuItem.carbs,
                fat: line.menuItem.fat,
                fiber: line.menuItem.fiber,
                sugar: line.menuItem.sugar,
              ))
          .toList(growable: false);

      await orderRepository.placeOrder(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        deliveryFee: restaurant.deliveryFee,
        items: orderItems,
      );

      await _logOrderToCalorieTracker(
        restaurantName: restaurant.name,
        lines: lines,
      );

      cartController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed with ${restaurant.name} '
            '— added to your meals',
          ),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place order: $e')),
      );
    }
  }

  Future<void> _logOrderToCalorieTracker({
    required String restaurantName,
    required List<CartLine> lines,
  }) async {
    final orderTime = DateTime.now();
    final mealType = MealType.defaultForHour(orderTime.hour);
    for (final line in lines) {
      final qty = line.quantity.toDouble();
      final item = line.menuItem;
      final unit = line.quantity > 1 ? 'portions' : 'portion';
      await mealsController.add(
        name: item.name,
        type: mealType,
        quantity: qty,
        unit: unit,
        calories: item.calories * qty,
        protein: item.protein * qty,
        carbs: item.carbs * qty,
        fat: item.fat * qty,
        fiber: item.fiber * qty,
        sugar: item.sugar * qty,
        date: orderTime,
        notes: 'Ordered from $restaurantName',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Your order',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      body: ListenableBuilder(
        listenable: cartController,
        builder: (context, _) {
          if (cartController.isEmpty) {
            return const _EmptyCart();
          }
          return _CartContent(
            onPlaceOrder: _placeOrder,
            isPlacing: _isPlacing,
          );
        },
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
  final VoidCallback onPlaceOrder;
  final bool isPlacing;

  const _CartContent({required this.onPlaceOrder, required this.isPlacing});

  @override
  Widget build(BuildContext context) {
    final restaurant = cartController.restaurant;
    final balance = authController.currentUser?.balance ?? 0;
    final total = cartController.total;
    final canAfford = balance >= total;

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
              for (final line in cartController.lines) ...[
                _CartLineRow(line: line),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              _SummarySection(
                subtotal: cartController.subtotal,
                deliveryFee: cartController.deliveryFee,
                total: total,
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
                            ? 'Order · ${formatLei(total)}'
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
  final CartLine line;

  const _CartLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final item = line.menuItem;
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
                  item.name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatLei(item.price)} each',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                _QuantityControls(menuItemId: item.id, quantity: line.quantity),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatLei(line.lineTotal),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Remove',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minHeight: 28,
                  minWidth: 28,
                ),
                onPressed: () => cartController.remove(item.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int menuItemId;
  final int quantity;

  const _QuantityControls({
    required this.menuItemId,
    required this.quantity,
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
          _RoundIconButton(
            icon: Icons.remove,
            onPressed: () => cartController.decrement(menuItemId),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onPressed: () => cartController.increment(menuItemId),
          ),
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
