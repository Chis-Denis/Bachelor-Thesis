import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../entities/meal.dart';
import '../entities/meal_type.dart';
import 'date_format.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? dateLabel;

  const MealItem({
    super.key,
    required this.meal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        borderColor: _borderColorFor(meal.type),
        borderWidth: 1.5,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTypography.subheading.copyWith(fontSize: 19),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.type.label}  ·  ${formatTime(meal.date)}  ·  '
                    '${_formatQuantity(meal.quantity)} ${meal.unit}',
                    style: AppTypography.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.calories.toInt()} kcal  ·  '
                    'P ${meal.protein.toInt()}g  ·  '
                    'C ${meal.carbs.toInt()}g  ·  '
                    'F ${meal.fat.toInt()}g',
                    style: AppTypography.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateLabel!,
                      style: AppTypography.bodyMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _IconAction(
              icon: Icons.edit_outlined,
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            _IconAction(
              icon: Icons.delete_outline,
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

Color _borderColorFor(MealType type) {
  switch (type) {
    case MealType.breakfast:
      return AppColors.mealBreakfast;
    case MealType.lunch:
      return AppColors.mealLunch;
    case MealType.dinner:
      return AppColors.mealDinner;
    case MealType.snack:
      return AppColors.mealSnack;
  }
}

String _formatQuantity(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.iconButton,
      height: AppSizes.iconButton,
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppColors.textSecondary),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }
}
