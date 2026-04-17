import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../entities/meal.dart';
import 'date_format.dart';

class MealDetailsScreen extends StatelessWidget {
  final int mealId;
  const MealDetailsScreen({super.key, required this.mealId});

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
      body: FutureBuilder<Meal?>(
        future: mealsController.findById(mealId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading meal: ${snapshot.error}',
                style: AppTypography.bodyMuted,
                textAlign: TextAlign.center,
              ),
            );
          }
          final meal = snapshot.data;
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
  final Meal meal;
  const _Body({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                Text(
                  meal.name,
                  style: AppTypography.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${meal.type.label}  ·  '
                  '${_formatQuantity(meal.quantity)} ${meal.unit}',
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${formatDateRelative(meal.date)}  ·  '
                  '${formatTime(meal.date)}',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '${meal.calories.toInt()} kcal',
                  style: AppTypography.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    runSpacing: AppSpacing.md,
                    children: [
                      _MacroStat(
                        label: 'Protein',
                        value: '${meal.protein.toInt()}g',
                      ),
                      _MacroStat(
                        label: 'Carbs',
                        value: '${meal.carbs.toInt()}g',
                      ),
                      _MacroStat(
                        label: 'Fat',
                        value: '${meal.fat.toInt()}g',
                      ),
                      _MacroStat(
                        label: 'Fiber',
                        value: '${meal.fiber.toInt()}g',
                      ),
                      _MacroStat(
                        label: 'Sugar',
                        value: '${meal.sugar.toInt()}g',
                      ),
                    ],
                  ),
                ),
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Notes', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.xs),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(meal.notes!, style: AppTypography.body),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Back',
          variant: AppButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final String value;
  const _MacroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.subheading),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

String _formatQuantity(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}
