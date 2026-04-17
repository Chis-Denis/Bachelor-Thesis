import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../utils/money_formatter.dart';
import '../../orders/widgets/cart_complete_bar.dart';
import '../../orders/widgets/menu_item_popup.dart';
import '../entities/menu_item.dart';
import '../entities/restaurant.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  bool _isLoading = true;
  List<MenuItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items =
          await restaurantRepository.itemsForRestaurant(widget.restaurant.id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load menu: $e')),
      );
    }
  }

  void _openItemPopup(MenuItem item) {
    showMenuItemPopup(
      context,
      restaurant: widget.restaurant,
      item: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return AppScaffold(
      title: r.name,
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      bottomBar: const CartCompleteBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                _Header(restaurant: r),
                const SizedBox(height: AppSpacing.lg),
                ..._buildCategorySections(),
              ],
            ),
    );
  }

  List<Widget> _buildCategorySections() {
    if (_items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            'No menu items yet.',
            style: AppTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    final byCategory = <String, List<MenuItem>>{};
    final orderedCategories = <String>[];
    for (final item in _items) {
      final list = byCategory.putIfAbsent(item.category, () {
        orderedCategories.add(item.category);
        return <MenuItem>[];
      });
      list.add(item);
    }

    final widgets = <Widget>[];
    for (var i = 0; i < orderedCategories.length; i++) {
      final category = orderedCategories[i];
      final items = byCategory[category]!;
      if (i > 0) widgets.add(const SizedBox(height: AppSpacing.lg));
      widgets.add(_CategoryHeader(label: category));
      widgets.add(const SizedBox(height: AppSpacing.sm));
      for (var j = 0; j < items.length; j++) {
        if (j > 0) widgets.add(const SizedBox(height: AppSpacing.sm));
        widgets.add(_MenuItemRow(
          item: items[j],
          onTap: () => _openItemPopup(items[j]),
        ));
      }
    }
    return widgets;
  }
}

class _Header extends StatelessWidget {
  final Restaurant restaurant;

  const _Header({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            borderRadius: AppRadii.all8,
          ),
          alignment: Alignment.center,
          child: Text(
            restaurant.name.isEmpty ? '?' : restaurant.name[0].toUpperCase(),
            style: AppTypography.heading.copyWith(fontSize: 26),
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
                icon: Icons.star,
                label: restaurant.rating.toStringAsFixed(1),
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textPrimary),
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

class _CategoryHeader extends StatelessWidget {
  final String label;

  const _CategoryHeader({required this.label});

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

class _MenuItemRow extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const _MenuItemRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
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
                if (item.calories > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${item.calories.round()} kcal · '
                    'P ${item.protein.round()}g · '
                    'C ${item.carbs.round()}g · '
                    'F ${item.fat.round()}g',
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            formatLei(item.price),
            style: AppTypography.body
                .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
