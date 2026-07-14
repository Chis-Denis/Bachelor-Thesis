import 'package:flutter/material.dart';

import '../../domain/settings/food_unit.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import 'settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = SettingsViewModel(
      deps.getUserSettings,
      deps.saveUserSettings,
      widget.userId,
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    final success = await _viewModel.save();
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not save settings';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const AppScaffold(
        title: 'Settings',
        showBack: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final saving = _viewModel.isSaving;

    return AppScaffold(
      title: 'Settings',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          _SettingsSectionLabel(label: 'Nutrition'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: FoodUnit.values.map((unit) {
                final isLast = unit == FoodUnit.values.last;
                return Column(
                  children: [
                    _UnitTile(
                      unit: unit,
                      isSelected: _viewModel.defaultUnit == unit,
                      enabled: !saving,
                      onTap: () => _viewModel.selectDefaultUnit(unit),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppColors.divider),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SettingsSectionLabel(label: 'About'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                _AboutRow(
                  label: 'App',
                  value: 'CalorieTrack',
                ),
                const Divider(height: AppSpacing.lg, color: AppColors.divider),
                _AboutRow(
                  label: 'Version',
                  value: '1.0.0',
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(
            label: 'Save settings',
            onPressed: _save,
            isLoading: saving,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  final String label;

  const _SettingsSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final FoodUnit unit;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _UnitTile({
    required this.unit,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.label, style: AppTypography.body),
                  Text(
                    'Default unit: ${unit.symbol}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.accent,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                size: 20,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(value,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            )),
      ],
    );
  }
}
