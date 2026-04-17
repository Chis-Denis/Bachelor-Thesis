import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/service_locator.dart';
import '../../../design/design.dart';
import '../entities/food.dart';
import '../entities/food_data_type.dart';
import '../entities/food_source.dart';
import '../services/food_repository.dart';

class FoodSearchScreen extends StatefulWidget {
  final String initialQuery;

  const FoodSearchScreen({super.key, this.initialQuery = ''});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  late final TextEditingController _query;
  Timer? _debounce;
  int _requestId = 0;

  bool _isLoading = false;
  String? _remoteError;
  List<Food> _results = const [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      _runSearch(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _results = const [];
        _remoteError = null;
        _hasSearched = false;
      });
      return;
    }
    final id = ++_requestId;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    final FoodSearchResult result;
    try {
      result = await foodRepository.search(query);
    } catch (e) {
      if (id != _requestId || !mounted) return;
      setState(() {
        _isLoading = false;
        _results = const [];
        _remoteError = 'Search failed: $e';
      });
      return;
    }
    if (id != _requestId || !mounted) return;
    setState(() {
      _isLoading = false;
      _results = result.foods;
      _remoteError = result.remoteError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Search foods',
      showBack: true,
      padding: EdgeInsets.zero,
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
              controller: _query,
              label: 'Food name',
              autofocus: true,
              onChanged: _onQueryChanged,
              onSubmitted: _runSearch,
              suffix: _query.text.isEmpty
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
                        _query.clear();
                        _runSearch('');
                      },
                    ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return const _MessageView(
        message: 'Type a food name to search your library and USDA.',
      );
    }
    if (_isLoading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return _MessageView(
        message: _remoteError == null
            ? 'No matches found.'
            : 'No matches found.\n$_remoteError',
      );
    }

    final localResults =
        _results.where((f) => f.source == FoodSource.local).toList();
    final remoteResults =
        _results.where((f) => f.source == FoodSource.usda).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (localResults.isNotEmpty) ...[
          _SectionHeader(label: FoodSource.local.label),
          for (final food in localResults) _FoodRow(food: food),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (remoteResults.isNotEmpty) ...[
          _SectionHeader(label: FoodSource.usda.label),
          for (final food in remoteResults) _FoodRow(food: food),
        ],
        if (_remoteError != null && remoteResults.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              _remoteError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
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

class _FoodRow extends StatelessWidget {
  final Food food;

  const _FoodRow({required this.food});

  @override
  Widget build(BuildContext context) {
    final qty = _formatNumber(food.servingSize);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: () => Navigator.of(context).pop(food),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (food.source == FoodSource.usda) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _DataTypeBadge(dataType: food.dataType),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Per $qty ${food.servingUnit} · '
                    '${_formatNumber(food.calories)} kcal · '
                    'P ${_formatNumber(food.protein)}g · '
                    'C ${_formatNumber(food.carbs)}g · '
                    'F ${_formatNumber(food.fat)}g',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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

  String _formatNumber(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _DataTypeBadge extends StatelessWidget {
  final FoodDataType dataType;

  const _DataTypeBadge({required this.dataType});

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
        dataType.badgeLabel,
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

class _MessageView extends StatelessWidget {
  final String message;

  const _MessageView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
