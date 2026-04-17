import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../utils/money_formatter.dart';
import '../../restaurants/entities/menu_item.dart';
import '../../restaurants/entities/restaurant.dart';

Future<void> showMenuItemPopup(
  BuildContext context, {
  required Restaurant restaurant,
  required MenuItem item,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _MenuItemDialog(
      restaurant: restaurant,
      item: item,
    ),
  );
}

class _MenuItemDialog extends StatelessWidget {
  final Restaurant restaurant;
  final MenuItem item;

  const _MenuItemDialog({required this.restaurant, required this.item});

  Future<void> _onAddPressed(BuildContext context) async {
    if (cartController.conflictsWith(restaurant)) {
      final currentName = cartController.restaurant?.name ?? 'another place';
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
      cartController.clear();
    }

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      cartController.add(restaurant, item);
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
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
                AppSpacing.md,
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
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
