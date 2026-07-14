import 'package:flutter/material.dart';

import '../../design/design.dart';

class MultiSelectChipGroup<T> extends StatelessWidget {
  final List<T> items;
  final Set<T> selected;
  final String Function(T) labelOf;
  final void Function(T) onToggle;
  final bool enabled;

  const MultiSelectChipGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return _SelectableChip(
          label: labelOf(item),
          isSelected: isSelected,
          enabled: enabled,
          onTap: () => onToggle(item),
        );
      }).toList(),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: AppRadii.pill,
        ),
        child: Text(
          label,
          style: AppTypography.body.copyWith(
            color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
