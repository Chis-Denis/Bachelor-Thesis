import 'package:flutter/material.dart';

import '../../application/meals/meal_dto.dart';
import '../../application/shared/macros_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/number_format.dart';
import '../design/design.dart';
import '../profile/profile_screen.dart';
import '../restaurants/discover_screen.dart';
import 'create_meal_screen.dart';
import 'home_view_model.dart';
import 'meal_details_screen.dart';
import 'meal_history_screen.dart';
import 'meal_item.dart';
import 'update_meal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = HomeViewModel(deps.loadMeals, deps.deleteMeal, deps.mealsStore)
      ..addListener(_onChanged);
    _viewModel.load();
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
    final meals = _viewModel.todaysMeals;
    final isLoading = _viewModel.isLoading;

    return AppScaffold(
      title: 'CalorieTrack',
      maxWidth: AppSizes.contentMaxWidth,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      leading: IconButton(
        icon: const Icon(Icons.person_outline, size: 22),
        tooltip: 'Profile',
        onPressed: () => _open(const ProfileScreen()),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, size: 20),
          tooltip: 'History',
          onPressed: () => _open(const MealHistoryScreen()),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      bottomBar: _Footer(
        onTapRestaurants: () => _open(const DiscoverScreen()),
        onTapAdd: () => _open(const CreateMealScreen()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLoading && meals.isNotEmpty) ...[
            _DailyTotals(
                totals: _viewModel.todayTotals, mealCount: meals.length),
            const SizedBox(height: AppSpacing.md),
          ],
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _viewModel.load,
                    child: meals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                              bottom: AppSpacing.md,
                            ),
                            itemCount: meals.length,
                            itemBuilder: (context, index) {
                              final meal = meals[index];
                              return MealItem(
                                key: ValueKey(meal.id),
                                meal: meal,
                                onTap: () => _open(
                                  MealDetailsScreen(mealId: meal.id),
                                ),
                                onEdit: () => _open(
                                  UpdateMealScreen(mealId: meal.id),
                                ),
                                onDelete: () => _confirmDelete(meal),
                              );
                            },
                          ),
                  ),
          ),
        ],
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
                Icons.restaurant_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No meals for today', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the + button to add one',
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyTotals extends StatelessWidget {
  final MacrosDto totals;
  final int mealCount;

  const _DailyTotals({required this.totals, required this.mealCount});

  @override
  Widget build(BuildContext context) {
    final mealLabel =
        mealCount == 1 ? '1 meal logged' : '$mealCount meals logged';
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(mealLabel, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Column(
              children: [
                Text(
                  Numbers.macro(totals.calories),
                  style: AppTypography.heading.copyWith(fontSize: 36),
                ),
                Text('kcal', style: AppTypography.bodyMuted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MacroColumn(
                label: 'Protein',
                value: '${Numbers.macro(totals.protein)}g',
                color: const Color(0xFF6366F1),
              ),
              _MacroDivider(),
              _MacroColumn(
                label: 'Carbs',
                value: '${Numbers.macro(totals.carbs)}g',
                color: const Color(0xFFF59E0B),
              ),
              _MacroDivider(),
              _MacroColumn(
                label: 'Fat',
                value: '${Numbers.macro(totals.fat)}g',
                color: const Color(0xFFEC4899),
              ),
              _MacroDivider(),
              _MacroColumn(
                label: 'Fiber',
                value: '${Numbers.macro(totals.fiber)}g',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _MacroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.divider,
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onTapRestaurants;
  final VoidCallback onTapAdd;

  const _Footer({required this.onTapRestaurants, required this.onTapAdd});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: _FooterAction(
                  icon: Icons.storefront_outlined,
                  label: 'Restaurants',
                  onTap: onTapRestaurants,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _FooterAction(
                  icon: Icons.add,
                  label: 'Add meal',
                  onTap: onTapAdd,
                  primary: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = primary ? AppColors.accent : AppColors.surface;
    final foreground = primary ? AppColors.textOnDark : AppColors.textPrimary;
    final border = primary ? AppColors.accent : AppColors.borderStrong;

    return SizedBox(
      height: AppSizes.buttonHeight,
      child: Material(
        color: background,
        borderRadius: AppRadii.all8,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.all8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.all8,
              border: Border.all(color: border, width: 1),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: foreground),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.button.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
