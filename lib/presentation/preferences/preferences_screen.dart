import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/constants/preferences_constants.dart';
import '../../domain/preferences/dietary_restriction.dart';
import '../../domain/preferences/food_allergy.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import '../meals/home_screen.dart';
import 'preferences_view_model.dart';
import 'widgets/health_goal_selector.dart';
import 'widgets/multi_select_chip_group.dart';

class PreferencesScreen extends StatefulWidget {
  final int userId;
  final bool isOnboarding;

  const PreferencesScreen({
    super.key,
    required this.userId,
    this.isOnboarding = false,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late final PreferencesViewModel _viewModel;
  final _calorieController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = PreferencesViewModel(
      deps.getMealPreferences,
      deps.saveMealPreferences,
      widget.userId,
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final target = _viewModel.dailyCalorieTarget;
    final text = target == null ? '' : target.toString();
    if (_calorieController.text != text) {
      _calorieController.text = text;
    }
    setState(() {});
  }

  Future<void> _save() async {
    _commitCalorieField();
    final success = await _viewModel.save();
    if (!mounted) return;
    if (!success) {
      _showError();
      return;
    }
    if (widget.isOnboarding) {
      _goToHome();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _skip() async {
    final success = await _viewModel.saveDefaults();
    if (!mounted) return;
    if (!success) {
      _showError();
      return;
    }
    _goToHome();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showError() {
    final message = _viewModel.errorMessage ?? 'Could not save preferences';
    _viewModel.clearError();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _commitCalorieField() {
    final raw = _calorieController.text.trim();
    if (raw.isEmpty) {
      _viewModel.setCalorieTarget(null);
      return;
    }
    final parsed = int.tryParse(raw);
    if (parsed == null) return;
    final clamped = parsed.clamp(
      PreferencesConstants.minCalorieTarget,
      PreferencesConstants.maxCalorieTarget,
    );
    _viewModel.setCalorieTarget(clamped);
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return AppScaffold(
        title: widget.isOnboarding ? 'Set up your profile' : 'Meal preferences',
        showBack: !widget.isOnboarding,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final saving = _viewModel.isSaving;

    return AppScaffold(
      title: widget.isOnboarding ? 'Set up your profile' : 'Meal preferences',
      showBack: !widget.isOnboarding,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isOnboarding) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tell us about your food preferences so we can personalise your experience.',
                style: AppTypography.bodyMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ] else
              const SizedBox(height: AppSpacing.sm),
            _SectionHeader(label: 'Health goal'),
            const SizedBox(height: AppSpacing.md),
            HealthGoalSelector(
              selected: _viewModel.healthGoal,
              onSelect: _viewModel.selectHealthGoal,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Dietary style'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Select all that apply.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            MultiSelectChipGroup<DietaryRestriction>(
              items: DietaryRestriction.values,
              selected: _viewModel.dietaryRestrictions,
              labelOf: (r) => r.label,
              onToggle: _viewModel.toggleDietaryRestriction,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Food allergies'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'We will highlight items that may contain these.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            MultiSelectChipGroup<FoodAllergy>(
              items: FoodAllergy.values,
              selected: _viewModel.allergies,
              labelOf: (a) => a.label,
              onToggle: _viewModel.toggleAllergy,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Daily calorie target'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Optional. Leave blank to track without a target.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _calorieController,
              label: 'Calories (kcal)',
              enabled: !saving,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              helperText:
                  '${PreferencesConstants.minCalorieTarget}–${PreferencesConstants.maxCalorieTarget} kcal',
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionHeader(label: 'Meals per day'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'How many meals do you typically eat?',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            _MealsPerDayStepper(
              value: _viewModel.mealsPerDay,
              onChanged: _viewModel.setMealsPerDay,
              enabled: !saving,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: widget.isOnboarding ? 'Save & continue' : 'Save changes',
              onPressed: _save,
              isLoading: saving,
            ),
            if (widget.isOnboarding) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Skip for now',
                variant: AppButtonVariant.secondary,
                onPressed: saving ? null : _skip,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.subheading);
  }
}

class _MealsPerDayStepper extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  final bool enabled;

  const _MealsPerDayStepper({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: enabled && value > PreferencesConstants.minMealsPerDay
              ? () => onChanged(value - 1)
              : null,
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(
          '$value meal${value == 1 ? '' : 's'}',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: AppSpacing.lg),
        _StepButton(
          icon: Icons.add,
          onTap: enabled && value < PreferencesConstants.maxMealsPerDay
              ? () => onChanged(value + 1)
              : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.accentDisabled,
          ),
          borderRadius: AppRadii.all8,
          color: AppColors.surface,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? AppColors.textPrimary : AppColors.accentDisabled,
        ),
      ),
    );
  }
}
