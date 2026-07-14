import 'package:flutter/material.dart';

import '../../application/meals/meal_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/date_format.dart';
import '../design/design.dart';
import 'meal_details_screen.dart';
import 'meal_history_view_model.dart';
import 'meal_item.dart';
import 'update_meal_screen.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  late final MealHistoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel =
        MealHistoryViewModel(deps.loadMeals, deps.deleteMeal, deps.mealsStore)
          ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final error = _viewModel.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      _viewModel.clearError();
    }
    setState(() {});
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmDelete(MealDto meal) async {
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
    if (confirmed == true) await _viewModel.delete(meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final meals = _viewModel.pastMeals;
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
        onRefresh: _viewModel.load,
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
                    onTap: () => _open(MealDetailsScreen(mealId: meal.id)),
                    onEdit: () => _open(UpdateMealScreen(mealId: meal.id)),
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
              const Icon(Icons.history, size: 40, color: AppColors.textMuted),
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
