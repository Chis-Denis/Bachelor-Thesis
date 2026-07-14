import 'package:flutter/material.dart';

import '../../application/auth/auth_form_rules.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import 'change_password_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  late final ChangePasswordViewModel _viewModel;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void initState() {
    super.initState();
    _viewModel = ChangePasswordViewModel(AppScope.of(context).changePassword)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _viewModel.submit(
      _currentController.text,
      _newController.text,
    );
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not update password';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = _viewModel.isSubmitting;
    return AppScaffold(
      showBack: true,
      title: 'Change password',
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter your current password, then choose a new one.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _currentController,
                label: 'Current password',
                enabled: !submitting,
                obscureText: _obscureCurrent,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.next,
                validator: AuthFormRules.required,
                suffix: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _newController,
                label: 'New password',
                helperText: 'At least 8 characters.',
                enabled: !submitting,
                obscureText: _obscureNew,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: AuthFormRules.password,
                suffix: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirmController,
                label: 'Confirm new password',
                enabled: !submitting,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value != _newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Update password',
                onPressed: _submit,
                isLoading: submitting,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed:
                    submitting ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
