import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../utils/money_formatter.dart';
import '../../auth/screens/login_screen.dart';
import '../../orders/screens/order_history_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon')),
    );
  }

  void _openChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _openOrderHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
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

    await authController.logout();
    await mealsController.load();
    if (!mounted) return;
    await navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.currentUser;
    return AppScaffold(
      title: 'Profile',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      body: user == null
          ? Center(
              child: Text(
                'Not signed in',
                style: AppTypography.bodyMuted,
              ),
            )
          : ListView(
              children: [
                const SizedBox(height: AppSpacing.sm),
                _Header(username: user.username),
                const SizedBox(height: AppSpacing.lg),
                _WalletCard(balance: user.balance),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(label: 'Account'),
                const SizedBox(height: AppSpacing.xs),
                _ProfileTile(
                  icon: Icons.tune,
                  label: 'Meal preferences',
                  onTap: () => _showComingSoon('Meal preferences'),
                ),
                _ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order history',
                  onTap: _openOrderHistory,
                ),
                _ProfileTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => _showComingSoon('Settings'),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(label: 'Security'),
                const SizedBox(height: AppSpacing.xs),
                _ProfileTile(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: _openChangePassword,
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
            style: AppTypography.heading.copyWith(
              color: AppColors.textPrimary,
            ),
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

  const _WalletCard({required this.balance});

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
        ],
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
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
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
