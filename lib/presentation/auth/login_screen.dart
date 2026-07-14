import 'package:flutter/material.dart';

import '../../application/auth/auth_form_rules.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import '../meals/home_screen.dart';
import '../preferences/preferences_screen.dart';
import 'login_view_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginViewModel _viewModel;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = LoginViewModel(deps.loginUser, deps.loadMeals)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _viewModel.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not sign in';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final next = await _resolveNextScreen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  Future<Widget> _resolveNextScreen() async {
    final deps = AppScope.of(context);
    final userId = deps.session.userId;
    if (userId == null) return const HomeScreen();
    final preferences = await deps.getMealPreferences(userId);
    if (preferences == null) {
      return PreferencesScreen(userId: userId, isOnboarding: true);
    }
    return const HomeScreen();
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = _viewModel.isSubmitting;
    return AppScaffold(
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'CalorieTrack',
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                controller: _usernameController,
                label: 'Username',
                enabled: !submitting,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
                validator: AuthFormRules.required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                enabled: !submitting,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
                validator: AuthFormRules.required,
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
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Sign in',
                onPressed: _login,
                isLoading: submitting,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: "Don't have an account? Register",
                variant: AppButtonVariant.text,
                onPressed: submitting ? null : _goToRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
