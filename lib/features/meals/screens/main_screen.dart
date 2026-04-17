import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../restaurants/screens/discover_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../entities/meal.dart';
import '../entities/meal_type.dart';
import 'create_meal_screen.dart';
import 'date_format.dart';
import 'meal_details_screen.dart';
import 'meal_history_screen.dart';
import 'meal_item.dart';
import 'update_meal_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    mealsController.addListener(_rebuild);
    authController.addListener(_rebuild);
  }

  @override
  void dispose() {
    mealsController.removeListener(_rebuild);
    authController.removeListener(_rebuild);
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

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateMealScreen()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MealHistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToFoods() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiscoverScreen()),
    );
  }

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
        .where((m) => isSameDay(m.date, now))
        .toList();
    meals.sort((a, b) {
      final slotCompare = _mealSlot(a).compareTo(_mealSlot(b));
      if (slotCompare != 0) return slotCompare;
      return a.date.compareTo(b.date);
    });
    final isLoading = mealsController.isLoading;

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
        onPressed: _navigateToProfile,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, size: 20),
          tooltip: 'History',
          onPressed: _navigateToHistory,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      bottomBar: _MainFooter(
        onTapFoods: _navigateToFoods,
        onTapAdd: _navigateToCreate,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLoading && meals.isNotEmpty) ...[
            _DailyTotals(meals: meals),
            const SizedBox(height: AppSpacing.md),
          ],
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: meals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            key: const Key('meals_list'),
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
                                onTap: () => _navigateToDetails(meal),
                                onEdit: () => _navigateToEdit(meal),
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

int _mealSlot(Meal meal) {
  switch (meal.type) {
    case MealType.breakfast:
      return 0;
    case MealType.snack:
      final hour = meal.date.hour;
      if (hour < 11) return 1;
      if (hour < 16) return 3;
      return 5;
    case MealType.lunch:
      return 2;
    case MealType.dinner:
      return 4;
  }
}

class _DailyTotals extends StatelessWidget {
  final List<Meal> meals;

  const _DailyTotals({required this.meals});

  @override
  Widget build(BuildContext context) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    double fiber = 0;
    double sugar = 0;
    for (final m in meals) {
      calories += m.calories;
      protein += m.protein;
      carbs += m.carbs;
      fat += m.fat;
      fiber += m.fiber;
      sugar += m.sugar;
    }

    final mealLabel = meals.length == 1 ? '1 meal' : '${meals.length} meals';

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Today', style: AppTypography.caption),
              Text(mealLabel, style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              '${_fmt(calories)} kcal',
              style: AppTypography.heading,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: [
              _MacroStat(label: 'P', value: protein),
              _MacroStat(label: 'C', value: carbs),
              _MacroStat(label: 'F', value: fat),
              _MacroStat(label: 'Fiber', value: fiber),
              _MacroStat(label: 'Sugar', value: sugar),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v.abs() < 0.05) return '0';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(0);
  }
}

class _MainFooter extends StatelessWidget {
  final VoidCallback onTapFoods;
  final VoidCallback onTapAdd;

  const _MainFooter({required this.onTapFoods, required this.onTapAdd});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
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
                  icon: Icons.restaurant_menu,
                  label: 'Foods',
                  onTap: onTapFoods,
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

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;

  const _MacroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyMuted,
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: '${_fmt(value)}g',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v.abs() < 0.05) return '0';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(0);
  }
}
