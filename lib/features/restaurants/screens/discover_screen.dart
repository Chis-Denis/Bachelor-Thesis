import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../../../utils/money_formatter.dart';
import '../../orders/screens/order_history_screen.dart';
import '../../orders/widgets/cart_complete_bar.dart';
import '../../orders/widgets/menu_item_popup.dart';
import '../../profile/screens/profile_screen.dart';
import '../entities/menu_item.dart';
import '../entities/restaurant.dart';
import 'restaurant_menu_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _queryController = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;

  bool _isLoading = true;
  String _activeQuery = '';
  List<RestaurantWithMatches> _results = const [];

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String value) async {
    final id = ++_requestId;
    setState(() {
      _isLoading = true;
      _activeQuery = value.trim();
    });
    try {
      final results = await restaurantRepository.search(value);
      if (id != _requestId || !mounted) return;
      setState(() {
        _isLoading = false;
        _results = results;
      });
    } catch (e) {
      if (id != _requestId || !mounted) return;
      setState(() {
        _isLoading = false;
        _results = const [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load restaurants: $e')),
      );
    }
  }

  void _onSuggestMeal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI meal suggestions coming soon')),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
    );
  }

  void _openRestaurantMenu(RestaurantWithMatches entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantMenuScreen(restaurant: entry.restaurant),
      ),
    );
  }

  void _openItemPopup(Restaurant restaurant, MenuItem item) {
    showMenuItemPopup(context, restaurant: restaurant, item: item);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Foods',
      leading: IconButton(
        icon: const Icon(Icons.person_outline, size: 22),
        tooltip: 'Profile',
        onPressed: _navigateToProfile,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined, size: 22),
          tooltip: 'Previous orders',
          onPressed: _navigateToOrderHistory,
        ),
      ],
      maxWidth: AppSizes.contentMaxWidth,
      padding: EdgeInsets.zero,
      bottomBar: const CartCompleteBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _queryController,
                  label: 'Search food, meal, or restaurant',
                  autofocus: false,
                  onChanged: _onQueryChanged,
                  onSubmitted: _runSearch,
                  suffix: _queryController.text.isEmpty
                      ? const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: 'Clear',
                          onPressed: () {
                            _queryController.clear();
                            _runSearch('');
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SuggestMealButton(onPressed: _onSuggestMeal),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      final message = _activeQuery.isEmpty
          ? 'No restaurants yet.'
          : 'No matches for "$_activeQuery".';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _RestaurantCard(
            entry: item,
            onTap: () => _openRestaurantMenu(item),
            onItemTap: (menuItem) =>
                _openItemPopup(item.restaurant, menuItem),
          ),
        );
      },
    );
  }
}

class _SuggestMealButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SuggestMealButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: Material(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.all8,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.all8,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.all8,
              border: Border.all(color: AppColors.borderStrong, width: 1),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Suggest a meal',
                  style: AppTypography.button.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantWithMatches entry;
  final VoidCallback onTap;
  final ValueChanged<MenuItem> onItemTap;

  const _RestaurantCard({
    required this.entry,
    required this.onTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = entry.restaurant;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RestaurantAvatar(name: r.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: AppTypography.subheading.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.cuisine,
                      style: AppTypography.bodyMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RatingChip(rating: r.rating),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.delivery_dining_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${formatLei(r.deliveryFee)} delivery',
                style: AppTypography.caption,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.schedule_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '~${r.estimatedMinutes} min',
                style: AppTypography.caption,
              ),
            ],
          ),
          if (entry.matchedItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: entry.matchedItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = entry.matchedItems[index];
                  return _MatchedItemChip(
                    item: item,
                    onTap: () => onItemTap(item),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestaurantAvatar extends StatelessWidget {
  final String name;

  const _RestaurantAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.all8,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.subheading.copyWith(
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double rating;

  const _RatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: AppColors.textPrimary),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchedItemChip extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const _MatchedItemChip({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.all8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.all8,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.all8,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatLei(item.price),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.calories > 0)
                    Text(
                      '${item.calories.toInt()} kcal',
                      style: AppTypography.caption,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
