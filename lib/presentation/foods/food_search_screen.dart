import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/foods/food_dto.dart';
import '../../application/foods/food_source_view.dart';
import '../../application/shared/macros_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/food_labels.dart';
import '../common/formatters/number_format.dart';
import '../design/design.dart';
import 'food_search_view_model.dart';

class FoodSearchScreen extends StatefulWidget {
  final String initialQuery;

  const FoodSearchScreen({super.key, this.initialQuery = ''});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  late final TextEditingController _query;
  late final FoodSearchViewModel _viewModel;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
    _viewModel = FoodSearchViewModel(AppScope.of(context).searchFoods)
      ..addListener(_onChanged);
    if (widget.initialQuery.trim().isNotEmpty) {
      _viewModel.search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _viewModel.dispose();
    _query.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _viewModel.search(value));
  }

  void _runSearch(String value) {
    _query.text = value;
    _query.selection = TextSelection.collapsed(offset: value.length);
    _viewModel.search(value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search foods',
      showBack: true,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          _SearchBar(
            controller: _query,
            onChanged: _onQueryChanged,
            onSubmitted: _viewModel.search,
            onClear: () {
              _query.clear();
              _viewModel.search('');
            },
          ),
          if (_viewModel.isLoading && _viewModel.results.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_viewModel.hasSearched) {
      return _IdleView(onSuggestionTap: _runSearch);
    }
    if (_viewModel.isLoading && _viewModel.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.results.isEmpty) {
      return _EmptySearchView(
        query: _query.text,
        remoteError: _viewModel.remoteError,
      );
    }

    final local = _viewModel.results
        .where((food) => food.source == FoodSourceView.local)
        .toList();
    final remote = _viewModel.results
        .where((food) => food.source == FoodSourceView.usda)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        if (local.isNotEmpty) ...[
          _SectionHeader(label: FoodLabels.source(FoodSourceView.local)),
          const SizedBox(height: AppSpacing.xs),
          for (final food in local) _FoodRow(food: food),
          const SizedBox(height: AppSpacing.md),
        ],
        if (remote.isNotEmpty) ...[
          _SectionHeader(label: FoodLabels.source(FoodSourceView.usda)),
          const SizedBox(height: AppSpacing.xs),
          for (final food in remote) _FoodRow(food: food),
        ],
        if (_viewModel.remoteError != null && remote.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              _viewModel.remoteError!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted,
            ),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: AppTextField(
        controller: controller,
        label: 'Food name',
        autofocus: true,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        suffix: controller.text.isEmpty
            ? const Icon(Icons.search, size: 20, color: AppColors.textSecondary)
            : IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.textSecondary),
                tooltip: 'Clear',
                onPressed: onClear,
              ),
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  static const _suggestions = [
    'Chicken breast',
    'Scrambled eggs',
    'White rice',
    'Salmon fillet',
    'Avocado',
    'Oatmeal',
    'Greek yogurt',
    'Banana',
    'Whole milk',
    'Cheddar cheese',
    'Pasta',
    'Ground beef',
    'Sweet potato',
    'Almonds',
    'Cottage cheese',
    'Tuna',
  ];

  const _IdleView({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Common foods', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap a suggestion to search, or type any food name above.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _suggestions
                .map((s) => _SuggestionChip(
                      label: s,
                      onTap: () => onSuggestionTap(s),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _InfoBanner(),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.all8,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Searches your saved library first, then the USDA database of over 300,000 foods.',
              style: AppTypography.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  final String query;
  final String? remoteError;

  const _EmptySearchView({required this.query, this.remoteError});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              query.trim().isEmpty ? 'No results' : 'No results for "$query"',
              style: AppTypography.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              remoteError ?? 'Try a different spelling or a more general term.',
              style: AppTypography.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _FoodRow extends StatelessWidget {
  final FoodDto food;

  const _FoodRow({required this.food});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => Navigator.of(context).pop(food),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (food.source == FoodSourceView.usda) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _DataTypeBadge(label: FoodLabels.badge(food.dataType)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Per ${Numbers.serving(food.servingSize)} ${food.servingUnit}',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 2),
                  _MacroRow(macros: food.macros),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _CalorieBadge(calories: food.macros.calories),
          ],
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  final MacrosDto macros;

  const _MacroRow({required this.macros});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MacroPill(
            label: 'P', value: macros.protein, color: const Color(0xFF6366F1)),
        const SizedBox(width: 6),
        _MacroPill(
            label: 'C', value: macros.carbs, color: const Color(0xFFF59E0B)),
        const SizedBox(width: 6),
        _MacroPill(
            label: 'F', value: macros.fat, color: const Color(0xFFEC4899)),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadii.all4,
      ),
      child: Text(
        '$label ${Numbers.serving(value)}g',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _CalorieBadge extends StatelessWidget {
  final double calories;

  const _CalorieBadge({required this.calories});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Numbers.serving(calories),
          style: AppTypography.subheading.copyWith(fontSize: 17),
        ),
        Text('kcal', style: AppTypography.caption),
      ],
    );
  }
}

class _DataTypeBadge extends StatelessWidget {
  final String label;

  const _DataTypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: AppRadii.all4,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
