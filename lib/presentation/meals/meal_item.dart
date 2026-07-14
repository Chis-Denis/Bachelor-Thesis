import 'package:flutter/material.dart';

import '../../application/meals/meal_dto.dart';
import '../common/formatters/date_format.dart';
import '../common/formatters/meal_type_label.dart';
import '../common/formatters/number_format.dart';
import '../design/design.dart';

class MealItem extends StatelessWidget {
  final MealDto meal;
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(child: _MealInfo(meal: meal, dateLabel: dateLabel)),
            const SizedBox(width: AppSpacing.sm),
            _RightSection(meal: meal, onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _MealInfo extends StatelessWidget {
  final MealDto meal;
  final String? dateLabel;

  const _MealInfo({required this.meal, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          meal.name,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            _TypeBadge(meal: meal),
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatTime(meal.date),
              style: AppTypography.caption,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${Numbers.quantity(meal.quantity)} ${meal.unit}',
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'P ${meal.macros.protein.toInt()}g · '
          'C ${meal.macros.carbs.toInt()}g · '
          'F ${meal.macros.fat.toInt()}g',
          style: AppTypography.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (dateLabel != null) ...[
          const SizedBox(height: 2),
          Text(dateLabel!, style: AppTypography.caption),
        ],
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final MealDto meal;

  const _TypeBadge({required this.meal});

  @override
  Widget build(BuildContext context) {
    final color = MealTypeLabel.color(meal.type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.all4,
      ),
      child: Text(
        MealTypeLabel.text(meal.type),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _RightSection extends StatelessWidget {
  final MealDto meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RightSection({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _CalorieBadge(calories: meal.macros.calories),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      ],
    );
  }
}

class _CalorieBadge extends StatelessWidget {
  final double calories;

  const _CalorieBadge({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          calories.toInt().toString(),
          style: AppTypography.subheading.copyWith(fontSize: 18),
        ),
        Text('kcal', style: AppTypography.caption),
      ],
    );
  }
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
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 18, color: AppColors.textSecondary),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
