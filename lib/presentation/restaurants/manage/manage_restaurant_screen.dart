import 'package:flutter/material.dart';

import '../../../application/restaurants/menu_item_dto.dart';
import '../../common/app_scope.dart';
import '../../common/formatters/money_format.dart';
import '../../design/design.dart';
import '../../issues/issues_list_screen.dart';
import 'manage_restaurant_view_model.dart';
import 'menu_item_form_screen.dart';
import 'restaurant_form_screen.dart';

class ManageRestaurantScreen extends StatefulWidget {
  const ManageRestaurantScreen({super.key});

  @override
  State<ManageRestaurantScreen> createState() => _ManageRestaurantScreenState();
}

class _ManageRestaurantScreenState extends State<ManageRestaurantScreen> {
  late final ManageRestaurantViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _viewModel = ManageRestaurantViewModel(
      deps.getMyRestaurant,
      deps.getRestaurantMenu,
      deps.deleteMenuItem,
    )..addListener(_onChanged);
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

  Future<void> _openForm(Widget screen) async {
    final changed = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed == true) await _viewModel.load();
  }

  Future<void> _confirmDelete(MenuItemDto item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Remove "${item.name}" from your menu?'),
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
    if (confirmed == true) await _viewModel.deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manage restaurant',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.restaurant == null
              ? _EmptyState(
                  onCreate: () => _openForm(const RestaurantFormScreen()))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final restaurant = _viewModel.restaurant!;
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: AppTypography.subheading),
                    const SizedBox(height: 2),
                    Text(
                      '${restaurant.cuisine} · ${formatLei(restaurant.deliveryFee)} '
                      'delivery · ~${restaurant.estimatedMinutes} min',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    _openForm(RestaurantFormScreen(initial: restaurant)),
                child: const Text('Edit'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionTile(
          icon: Icons.flag_outlined,
          label: 'Reported issues',
          subtitle: 'Review client complaints with the AI photo checker',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const IssuesListScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menu (${_viewModel.menu.length})',
                style: AppTypography.subheading),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add item'),
              onPressed: () => _openForm(
                MenuItemFormScreen(restaurantId: restaurant.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_viewModel.menu.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text('No menu items yet. Add your first dish.',
                style: AppTypography.bodyMuted, textAlign: TextAlign.center),
          )
        else
          ..._viewModel.menu.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MenuRow(
                  item: item,
                  onEdit: () => _openForm(MenuItemFormScreen(
                      restaurantId: restaurant.id, initial: item)),
                  onDelete: () => _confirmDelete(item),
                ),
              )),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined,
                size: 44, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No restaurant yet', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create your restaurant so clients can order from it.',
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Create restaurant', onPressed: onCreate),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuItemDto item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${item.category} · ${formatLei(item.price)} · '
                  '${item.macros.calories.round()} kcal',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.textSecondary,
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.textSecondary,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
