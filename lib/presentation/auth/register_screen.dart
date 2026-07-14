import 'package:flutter/material.dart';

import '../../application/auth/auth_form_rules.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import 'register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late final RegisterViewModel _viewModel;
  bool _obscurePassword = true;
  bool _isBusinessOwner = false;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(AppScope.of(context).registerUser)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final deps = AppScope.of(context);
    final username = _usernameController.text.trim();
    final userId = await _viewModel.register(
      username,
      _passwordController.text,
      isBusinessOwner: _isBusinessOwner,
    );
    if (!mounted) return;
    if (userId == null) {
      final message = _viewModel.errorMessage ?? 'Could not create account';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    if (_isBusinessOwner) {
      await deps.setUpBusinessDemo(
        ownerUserId: userId,
        ownerUsername: username,
      );
      if (!mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created. Please sign in.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = _viewModel.isSubmitting;
    return AppScaffold(
      showBack: true,
      title: 'Create account',
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
                'Choose a username and password',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                helperText: '3–20 characters. Letters, digits, underscore.',
                enabled: !submitting,
                autofillHints: const [AutofillHints.newUsername],
                textInputAction: TextInputAction.next,
                validator: AuthFormRules.username,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                helperText: 'At least 8 characters.',
                enabled: !submitting,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: AuthFormRules.password,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirmController,
                label: 'Confirm password',
                enabled: !submitting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _BusinessOwnerToggle(
                value: _isBusinessOwner,
                enabled: !submitting,
                onChanged: (value) => setState(() => _isBusinessOwner = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Create account',
                onPressed: _register,
                isLoading: submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessOwnerToggle extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BusinessOwnerToggle({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: enabled ? () => onChanged(!value) : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_outlined,
              size: 20, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'I own a restaurant',
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your menu and review client reports',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
