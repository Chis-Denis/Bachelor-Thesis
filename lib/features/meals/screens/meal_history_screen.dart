import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../entities/meal.dart';
import 'date_format.dart';
import 'meal_details_screen.dart';
import 'meal_item.dart';
import 'update_meal_screen.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    mealsController.addListener(_rebuild);
  }

  @override
  void dispose() {
    mealsController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (!mounted) return;
    final err = mealsController.errorMessage;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      mealsController.clearError();
    }
    setState(() {});
  }

  Future<void> _refresh() => mealsController.load();

  void _navigateToDetails(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealDetailsScreen(mealId: meal.id)),
    );
  }

  void _navigateToEdit(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateMealScreen(mealId: meal.id)),
    );
  }

  Future<void> _confirmDelete(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meal'),
        content: Text('Delete "${meal.name}"? This cannot be undone.'),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await mealsController.remove(meal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meals = mealsController.meals
        .where((m) => !isSameDay(m.date, now))
        .toList(growable: false);

    return AppScaffold(
      title: 'History',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: meals.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.lg,
                ),
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return MealItem(
                    key: ValueKey(meal.id),
                    meal: meal,
                    dateLabel: formatDateRelative(meal.date),
                    onTap: () => _navigateToDetails(meal),
                    onEdit: () => _navigateToEdit(meal),
                    onDelete: () => _confirmDelete(meal),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: AppSpacing.xxl * 2),
        Center(
          child: Column(
            children: [
              const Icon(
                Icons.history,
                size: 40,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No past meals', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Older meals will show up here',
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
