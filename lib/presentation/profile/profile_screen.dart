import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/constants/wallet_constants.dart';
import '../auth/login_screen.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import '../ordering/order_history_screen.dart';
import '../preferences/preferences_screen.dart';
import '../restaurants/manage/manage_restaurant_screen.dart';
import '../settings/settings_screen.dart';
import 'change_password_screen.dart';
import 'profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = ProfileViewModel(deps.session, deps.logoutUser, deps.addFunds)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _addMoney() async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _AddMoneyDialog(),
    );
    if (amount == null) return;
    final success = await _viewModel.addFunds(amount);
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not add funds';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${formatLei(amount)} to your wallet')),
    );
  }

  Future<void> _confirmLogout() async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Sign out of your account?'),
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
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _viewModel.logout();
    if (!mounted) return;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _viewModel.user;
    return AppScaffold(
      title: 'Profile',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: user == null
          ? Center(child: Text('Not signed in', style: AppTypography.bodyMuted))
          : ListView(
              children: [
                const SizedBox(height: AppSpacing.sm),
                _Header(username: user.username),
                const SizedBox(height: AppSpacing.lg),
                _WalletCard(balance: user.balance, onAddMoney: _addMoney),
                const SizedBox(height: AppSpacing.lg),
                if (user.isBusinessOwner) ...[
                  _SectionLabel(label: 'Business'),
                  const SizedBox(height: AppSpacing.xs),
                  _ProfileTile(
                    icon: Icons.storefront_outlined,
                    label: 'Manage my restaurant',
                    onTap: () => _open(const ManageRestaurantScreen()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _SectionLabel(label: 'Account'),
                const SizedBox(height: AppSpacing.xs),
                _ProfileTile(
                  icon: Icons.tune,
                  label: 'Meal preferences',
                  onTap: () {
                    final userId = _viewModel.user?.id;
                    if (userId == null) return;
                    _open(PreferencesScreen(userId: userId));
                  },
                ),
                _ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order history',
                  onTap: () => _open(const OrderHistoryScreen()),
                ),
                _ProfileTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    final userId = _viewModel.user?.id;
                    if (userId == null) return;
                    _open(SettingsScreen(userId: userId));
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(label: 'Security'),
                const SizedBox(height: AppSpacing.xs),
                _ProfileTile(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: () => _open(const ChangePasswordScreen()),
                ),
                _ProfileTile(
                  icon: Icons.logout,
                  label: 'Sign out',
                  onTap: _confirmLogout,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final String username;

  const _Header({required this.username});

  @override
  Widget build(BuildContext context) {
    final initial = username.isEmpty ? '?' : username[0].toUpperCase();
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.surfaceSunken,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTypography.heading.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(username, style: AppTypography.subheading),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback onAddMoney;

  const _WalletCard({required this.balance, required this.onAddMoney});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: AppRadii.all8,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet', style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(
                  formatLei(balance),
                  style: AppTypography.heading.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          _AddMoneyButton(onTap: onAddMoney),
        ],
      ),
    );
  }
}

class _AddMoneyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMoneyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: AppRadii.pill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.textOnDark),
              const SizedBox(width: 4),
              Text(
                'Add',
                style: AppTypography.button.copyWith(
                  color: AppColors.textOnDark,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMoneyDialog extends StatefulWidget {
  const _AddMoneyDialog();

  @override
  State<_AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<_AddMoneyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectPreset(double value) {
    _controller.text = value.toStringAsFixed(0);
    setState(() {});
  }

  void _submit() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) return;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.all12),
      title: const Text('Add money'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _controller,
            label: 'Amount (lei)',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: WalletConstants.topUpPresets
                .map((preset) => _PresetChip(
                      label: formatLei(preset),
                      onTap: () => _selectPreset(preset),
                    ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: AppTypography.body),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
