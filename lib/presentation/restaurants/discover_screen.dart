import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/restaurants/menu_item_dto.dart';
import '../../application/restaurants/restaurant_dto.dart';
import '../../application/restaurants/restaurant_match_dto.dart';
import '../../application/suggestions/meal_suggestion_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import '../ordering/cart_complete_bar.dart';
import '../ordering/menu_item_popup.dart';
import '../ordering/order_history_screen.dart';
import '../profile/profile_screen.dart';
import '../suggestions/suggestion_sheet.dart';
import 'discover_view_model.dart';
import 'restaurant_menu_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  final _queryController = TextEditingController();
  late final DiscoverViewModel _viewModel;
  Timer? _debounce;
  String? _selectedCuisine;

  @override
  void initState() {
    super.initState();
    _viewModel = DiscoverViewModel(AppScope.of(context).discoverRestaurants)
      ..addListener(_onChanged);
    _viewModel.search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _viewModel.dispose();
    _queryController.dispose();
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
    if (_selectedCuisine != null && !_cuisines.contains(_selectedCuisine)) {
      _selectedCuisine = null;
    }
    setState(() {});
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _viewModel.search(value));
  }

  void _suggestMeal() {
    showSuggestionSheet(
      context,
      suggestMeals: AppScope.of(context).suggestMeals,
      onSelect: _openSuggestion,
    );
  }

  Future<void> _openSuggestion(MealSuggestionDto suggestion) async {
    Navigator.of(context).pop();
    final deps = AppScope.of(context);
    final restaurant = await deps.getRestaurant(suggestion.restaurantId);
    if (!mounted || restaurant == null) return;
    final menu = await deps.getRestaurantMenu(restaurant.id);
    if (!mounted) return;
    final item = _findItem(menu.data, suggestion.menuItemId);
    if (item == null) {
      _open(RestaurantMenuScreen(restaurant: restaurant));
      return;
    }
    await showMenuItemPopup(context, restaurant: restaurant, item: item);
  }

  MenuItemDto? _findItem(List<MenuItemDto>? items, int menuItemId) {
    for (final item in items ?? const <MenuItemDto>[]) {
      if (item.id == menuItemId) return item;
    }
    return null;
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  List<RestaurantMatchDto> get _filteredResults {
    final cuisine = _selectedCuisine;
    if (cuisine == null) return _viewModel.results;
    return _viewModel.results
        .where((r) => r.restaurant.cuisine == cuisine)
        .toList();
  }

  List<String> get _cuisines {
    final seen = <String>{};
    return _viewModel.results
        .map((r) => r.restaurant.cuisine)
        .where(seen.add)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Restaurants',
      leading: IconButton(
        icon: const Icon(Icons.person_outline, size: 22),
        tooltip: 'Profile',
        onPressed: () => _open(const ProfileScreen()),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined, size: 22),
          tooltip: 'Previous orders',
          onPressed: () => _open(const OrderHistoryScreen()),
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
            child: AppTextField(
              controller: _queryController,
              label: 'Search restaurant or dish',
              onChanged: _onQueryChanged,
              onSubmitted: _viewModel.search,
              suffix: _queryController.text.isEmpty
                  ? const Icon(Icons.search,
                      size: 20, color: AppColors.textSecondary)
                  : IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                      tooltip: 'Clear',
                      onPressed: () {
                        _queryController.clear();
                        _viewModel.search('');
                      },
                    ),
            ),
          ),
          if (_cuisines.isNotEmpty)
            _CuisineFilterRow(
              cuisines: _cuisines,
              selected: _selectedCuisine,
              onSelect: (c) => setState(() {
                _selectedCuisine = _selectedCuisine == c ? null : c;
              }),
            ),
          _SuggestMealBanner(onPressed: _suggestMeal),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading && _viewModel.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = _filteredResults;

    if (results.isEmpty) {
      return _EmptyView(
        hasQuery:
            _queryController.text.trim().isNotEmpty || _selectedCuisine != null,
        query: _queryController.text.trim(),
        cuisine: _selectedCuisine,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final match = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _RestaurantCard(
            match: match,
            onTap: () =>
                _open(RestaurantMenuScreen(restaurant: match.restaurant)),
            onItemTap: (item) => showMenuItemPopup(
              context,
              restaurant: match.restaurant,
              item: item,
            ),
          ),
        );
      },
    );
  }
}

class _SuggestMealBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const _SuggestMealBanner({required this.onPressed});

  static const Color _aiColor = Color(0xFF6366F1);
  static const Color _aiBadgeBg = Color(0xFFEEF2FF);
  static const Color _aiBadgeBorder = Color(0xFFC7D2FE);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.all8,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.all8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadii.all8,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 17, color: _aiColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Suggest a meal for me',
                  style: AppTypography.body,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: _aiBadgeBg,
                    borderRadius: AppRadii.pill,
                    border: Border.all(color: _aiBadgeBorder),
                  ),
                  child: Text(
                    'AI',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _aiColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CuisineFilterRow extends StatelessWidget {
  final List<String> cuisines;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CuisineFilterRow({
    required this.cuisines,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: cuisines.map((cuisine) {
          final isSelected = selected == cuisine;
          return Padding(
            padding:
                const EdgeInsets.only(right: AppSpacing.sm, top: 6, bottom: 6),
            child: GestureDetector(
              onTap: () => onSelect(cuisine),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: AppRadii.pill,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  cuisine,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: isSelected
                        ? AppColors.textOnDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasQuery;
  final String query;
  final String? cuisine;

  const _EmptyView({
    required this.hasQuery,
    required this.query,
    required this.cuisine,
  });

  @override
  Widget build(BuildContext context) {
    final message = cuisine != null
        ? 'No $cuisine restaurants found.'
        : query.isNotEmpty
            ? 'No matches for "$query".'
            : 'No restaurants available.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined,
                size: 44, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTypography.subheading, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasQuery
                  ? 'Try a different search or remove the filter.'
                  : 'Check back soon for new restaurants.',
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantMatchDto match;
  final VoidCallback onTap;
  final ValueChanged<MenuItemDto> onItemTap;

  const _RestaurantCard({
    required this.match,
    required this.onTap,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final restaurant = match.restaurant;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(restaurant: restaurant),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.delivery_dining_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${formatLei(restaurant.deliveryFee)} delivery',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.schedule_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '~${restaurant.estimatedMinutes} min',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                if (match.matchedItems.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Matching dishes',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: match.matchedItems.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = match.matchedItems[index];
                        return _MatchedItemCard(
                          item: item,
                          onTap: () => onItemTap(item),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final RestaurantDto restaurant;

  const _CardHeader({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _RestaurantAvatar(name: restaurant.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: AppTypography.subheading.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: AppRadii.pill,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        restaurant.cuisine,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (restaurant.rating > 0) _RatingChip(rating: restaurant.rating),
        ],
      ),
    );
  }
}

class _RestaurantAvatar extends StatelessWidget {
  final String name;

  const _RestaurantAvatar({required this.name});

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
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final color = _colorFor(name);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.all12,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.subheading.copyWith(
          fontSize: 20,
          color: color,
          fontWeight: FontWeight.w700,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: AppRadii.pill,
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchedItemCard extends StatelessWidget {
  final MenuItemDto item;
  final VoidCallback onTap;

  const _MatchedItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.all8,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatLei(item.price),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.macros.calories > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: AppRadii.all4,
                    ),
                    child: Text(
                      '${item.macros.calories.toInt()} kcal',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
