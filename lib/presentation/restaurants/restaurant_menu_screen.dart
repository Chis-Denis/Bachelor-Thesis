import 'package:flutter/material.dart';

import '../../application/restaurants/menu_item_dto.dart';
import '../../application/restaurants/restaurant_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import '../ordering/cart_complete_bar.dart';
import '../ordering/menu_item_popup.dart';
import 'restaurant_menu_view_model.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final RestaurantDto restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  late final RestaurantMenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RestaurantMenuViewModel(AppScope.of(context).getRestaurantMenu)
      ..addListener(_onChanged);
    _viewModel.load(widget.restaurant.id);
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

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    return AppScaffold(
      title: restaurant.name,
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      bottomBar: const CartCompleteBar(),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _RestaurantHeader(restaurant: restaurant),
                const SizedBox(height: AppSpacing.lg),
                ..._buildCategorySections(),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
    );
  }

  List<Widget> _buildCategorySections() {
    if (_viewModel.items.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: _EmptyMenuView(),
        ),
      ];
    }

    final byCategory = <String, List<MenuItemDto>>{};
    final orderedCategories = <String>[];
    for (final item in _viewModel.items) {
      final list = byCategory.putIfAbsent(item.category, () {
        orderedCategories.add(item.category);
        return <MenuItemDto>[];
      });
      list.add(item);
    }

    final widgets = <Widget>[];
    for (var i = 0; i < orderedCategories.length; i++) {
      final category = orderedCategories[i];
      final items = byCategory[category]!;
      if (i > 0) widgets.add(const SizedBox(height: AppSpacing.xl));
      widgets.add(_CategorySection(
        category: category,
        items: items,
        onItemTap: (item) => showMenuItemPopup(
          context,
          restaurant: widget.restaurant,
          item: item,
        ),
      ));
    }
    return widgets;
  }
}

class _RestaurantHeader extends StatelessWidget {
  final RestaurantDto restaurant;

  const _RestaurantHeader({required this.restaurant});

  static const _avatarColors = [
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF3B82F6),
  ];

  Color _colorFor(String name) {
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % _avatarColors.length;
    return _avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(restaurant.name);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.2))),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadii.all12,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              restaurant.name.isEmpty ? '?' : restaurant.name[0].toUpperCase(),
              style: AppTypography.heading.copyWith(
                fontSize: 26,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            restaurant.name,
            style: AppTypography.heading.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            restaurant.cuisine,
            style: AppTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoPill(
                icon: Icons.delivery_dining_outlined,
                label: '${formatLei(restaurant.deliveryFee)} delivery',
              ),
              _InfoPill(
                icon: Icons.schedule_outlined,
                label: '~${restaurant.estimatedMinutes} min',
              ),
              if (restaurant.rating > 0)
                _InfoPill(
                  icon: Icons.star_rounded,
                  label: restaurant.rating.toStringAsFixed(1),
                  iconColor: const Color(0xFFF59E0B),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMenuView extends StatelessWidget {
  const _EmptyMenuView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_outlined,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No menu items yet', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.xs),
          Text('Check back soon', style: AppTypography.bodyMuted),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<MenuItemDto> items;
  final ValueChanged<MenuItemDto> onItemTap;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryHeader(label: category),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _MenuItemRow(
                item: item,
                onTap: () => onItemTap(item),
              ),
            )),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;

  const _CategoryHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: AppRadii.all4,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final MenuItemDto item;
  final VoidCallback onTap;

  const _MenuItemRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: AppTypography.bodyMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.macros.calories > 0) ...[
                  const SizedBox(height: 8),
                  _MacroRow(item: item),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _PriceColumn(price: item.price, onTap: onTap),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final MenuItemDto item;

  const _MacroRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalorieBadge(calories: item.macros.calories),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'P ${item.macros.protein.round()}g · '
          'C ${item.macros.carbs.round()}g · '
          'F ${item.macros.fat.round()}g',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _CalorieBadge extends StatelessWidget {
  final double calories;

  const _CalorieBadge({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.all4,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '${calories.round()} kcal',
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  final double price;
  final VoidCallback onTap;

  const _PriceColumn({required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatLei(price),
          style: AppTypography.body
              .copyWith(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadii.all8,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.add, size: 16, color: AppColors.textOnDark),
        ),
      ],
    );
  }
}
