import 'package:flutter/material.dart';

import '../../application/meals/meal_dto.dart';
import '../../application/shared/operation_result.dart';
import '../common/app_scope.dart';
import '../common/formatters/date_format.dart';
import '../common/formatters/meal_type_label.dart';
import '../common/formatters/number_format.dart';
import '../design/design.dart';

class MealDetailsScreen extends StatefulWidget {
  final int mealId;

  const MealDetailsScreen({super.key, required this.mealId});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  late final Future<OperationResult<MealDto?>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppScope.of(context).getMeal(widget.mealId);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Meal details',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: FutureBuilder<OperationResult<MealDto?>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final result = snapshot.data;
          if (result == null || !result.isSuccess) {
            return Center(
              child: Text(
                result?.error ?? 'Could not load meal',
                style: AppTypography.bodyMuted,
                textAlign: TextAlign.center,
              ),
            );
          }
          final meal = result.data;
          if (meal == null) {
            return Center(
              child: Text('Meal not found', style: AppTypography.bodyMuted),
            );
          }
          return _Body(meal: meal);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final MealDto meal;

  const _Body({required this.meal});

  @override
  Widget build(BuildContext context) {
    final typeColor = MealTypeLabel.color(meal.type);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          _TypeBadge(meal: meal, typeColor: typeColor),
          const SizedBox(height: AppSpacing.md),
          Text(
            meal.name,
            style: AppTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${Numbers.quantity(meal.quantity)} ${meal.unit}',
            style: AppTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${formatDateRelative(meal.date)}  ·  ${formatTime(meal.date)}',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          _CalorieSummary(calories: meal.macros.calories),
          const SizedBox(height: AppSpacing.lg),
          _MacroGrid(meal: meal),
          if (meal.notes != null && meal.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notes',
              style:
                  AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(meal.notes!, style: AppTypography.body),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final MealDto meal;
  final Color typeColor;

  const _TypeBadge({required this.meal, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.12),
          borderRadius: AppRadii.pill,
        ),
        child: Text(
          MealTypeLabel.text(meal.type),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: typeColor,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _CalorieSummary extends StatelessWidget {
  final double calories;

  const _CalorieSummary({required this.calories});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text('Total calories', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${calories.toInt()} kcal',
            style: AppTypography.heading.copyWith(fontSize: 32),
          ),
        ],
      ),
    );
  }
}

class _MacroGrid extends StatelessWidget {
  final MealDto meal;

  const _MacroGrid({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MacroCard(
          label: 'Protein',
          value: '${meal.macros.protein.toInt()}g',
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(width: AppSpacing.sm),
        _MacroCard(
          label: 'Carbs',
          value: '${meal.macros.carbs.toInt()}g',
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: AppSpacing.sm),
        _MacroCard(
          label: 'Fat',
          value: '${meal.macros.fat.toInt()}g',
          color: const Color(0xFFEC4899),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadii.all8,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.subheading.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
