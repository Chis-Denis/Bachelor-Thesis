import 'package:flutter/material.dart';

import '../../../domain/preferences/health_goal.dart';
import '../../design/design.dart';

class HealthGoalSelector extends StatelessWidget {
  final HealthGoal? selected;
  final void Function(HealthGoal?) onSelect;
  final bool enabled;

  const HealthGoalSelector({
    super.key,
    required this.selected,
    required this.onSelect,
    this.enabled = true,
  });

  static const Map<HealthGoal, IconData> _icons = {
    HealthGoal.loseWeight: Icons.trending_down_rounded,
    HealthGoal.gainMuscle: Icons.fitness_center_rounded,
    HealthGoal.maintainWeight: Icons.balance_rounded,
    HealthGoal.improveHealth: Icons.favorite_border_rounded,
    HealthGoal.exploreNew: Icons.explore_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final goal in HealthGoal.values) ...[
          if (goal != HealthGoal.values.first)
            const SizedBox(height: AppSpacing.sm),
          _GoalRow(
            goal: goal,
            icon: _icons[goal] ?? Icons.flag_outlined,
            isSelected: selected == goal,
            enabled: enabled,
            onTap: () => _handleTap(goal),
          ),
        ],
      ],
    );
  }

  void _handleTap(HealthGoal goal) {
    if (!enabled) return;
    onSelect(selected == goal ? null : goal);
  }
}

class _GoalRow extends StatelessWidget {
  final HealthGoal goal;
  final IconData icon;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _GoalRow({
    required this.goal,
    required this.icon,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        isSelected ? AppColors.textOnDark : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppRadii.all12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: foreground),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.label,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goal.description,
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? AppColors.textOnDark.withValues(alpha: 0.75)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.textOnDark,
              ),
          ],
        ),
      ),
    );
  }
}
