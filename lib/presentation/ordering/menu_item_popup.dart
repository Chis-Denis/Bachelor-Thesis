import 'package:flutter/material.dart';

import '../../application/restaurants/menu_item_dto.dart';
import '../../application/restaurants/restaurant_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';

Future<void> showMenuItemPopup(
  BuildContext context, {
  required RestaurantDto restaurant,
  required MenuItemDto item,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) =>
        _MenuItemDialog(restaurant: restaurant, item: item),
  );
}

class _MenuItemDialog extends StatelessWidget {
  final RestaurantDto restaurant;
  final MenuItemDto item;

  const _MenuItemDialog({required this.restaurant, required this.item});

  Future<void> _onAddPressed(BuildContext context) async {
    final cart = AppScope.of(context).cartService;

    if (cart.conflictsWith(restaurant)) {
      final currentName = cart.current.restaurant?.name ?? 'another place';
      final replace = await showDialog<bool>(
        context: context,
        builder: (confirmContext) => AlertDialog(
          title: const Text('Start a new order?'),
          content: Text(
            'Your cart contains items from $currentName. '
            'Adding items from ${restaurant.name} will clear it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(confirmContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(confirmContext).pop(true),
              child: const Text('Start new order'),
            ),
          ],
        ),
      );
      if (replace != true) return;
      cart.clear();
    }

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = cart.add(restaurant, item);
    if (!result.isSuccess) {
      messenger.showSnackBar(
        SnackBar(content: Text(result.error ?? 'Could not add item')),
      );
      return;
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('Added ${item.name} to your order'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.all12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTypography.heading.copyWith(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatLei(item.price),
                    style: AppTypography.subheading.copyWith(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (item.macros.calories > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    _MacroPillRow(item: item),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Add to order'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textOnDark,
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.all8,
                    ),
                  ),
                  onPressed: () => _onAddPressed(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPillRow extends StatelessWidget {
  final MenuItemDto item;

  const _MacroPillRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _NutritionPill(
          label: 'Calories',
          value: '${item.macros.calories.round()} kcal',
          color: AppColors.textPrimary,
          backgroundColor: AppColors.surfaceSunken,
        ),
        _NutritionPill(
          label: 'Protein',
          value: '${item.macros.protein.round()}g',
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFFEEF2FF),
        ),
        _NutritionPill(
          label: 'Carbs',
          value: '${item.macros.carbs.round()}g',
          color: const Color(0xFFB45309),
          backgroundColor: const Color(0xFFFEF3C7),
        ),
        _NutritionPill(
          label: 'Fat',
          value: '${item.macros.fat.round()}g',
          color: const Color(0xFFBE185D),
          backgroundColor: const Color(0xFFFCE7F3),
        ),
      ],
    );
  }
}

class _NutritionPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  const _NutritionPill({
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.all4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
