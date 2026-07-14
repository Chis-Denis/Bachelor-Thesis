import 'package:flutter/material.dart';

import '../../application/suggestions/meal_suggestion_dto.dart';
import '../../application/suggestions/suggest_meals.dart';
import '../common/formatters/money_format.dart';
import '../design/design.dart';
import 'suggestion_view_model.dart';

const Color _aiColor = Color(0xFF6366F1);
const Color _aiBadgeBg = Color(0xFFEEF2FF);
const Color _aiBadgeBorder = Color(0xFFC7D2FE);

Future<void> showSuggestionSheet(
  BuildContext context, {
  required SuggestMeals suggestMeals,
  required void Function(MealSuggestionDto suggestion) onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    builder: (_) => _SuggestionSheet(
      suggestMeals: suggestMeals,
      onSelect: onSelect,
    ),
  );
}

class _SuggestionSheet extends StatefulWidget {
  final SuggestMeals suggestMeals;
  final void Function(MealSuggestionDto) onSelect;

  const _SuggestionSheet({required this.suggestMeals, required this.onSelect});

  @override
  State<_SuggestionSheet> createState() => _SuggestionSheetState();
}

class _SuggestionSheetState extends State<_SuggestionSheet> {
  late final SuggestionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SuggestionViewModel(widget.suggestMeals)
      ..addListener(_onChanged);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DragHandle(),
            const SizedBox(height: AppSpacing.md),
            const _Header(),
            const SizedBox(height: AppSpacing.md),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const _LoadingState();
    }
    if (_viewModel.errorMessage != null) {
      return _ErrorState(
        message: _viewModel.errorMessage!,
        onRetry: _viewModel.load,
      );
    }
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _viewModel.suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final suggestion = _viewModel.suggestions[index];
          return _SuggestionCard(
            rank: index + 1,
            suggestion: suggestion,
            onTap: () => widget.onSelect(suggestion),
          );
        },
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: AppRadii.pill,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.auto_awesome_rounded, size: 20, color: _aiColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recommended for you', style: AppTypography.subheading),
              const SizedBox(height: 2),
              Text(
                'Matched to your goal, budget and what you ate today',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        const _AiBadge(),
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
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
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text('Finding your best matches…', style: AppTypography.bodyMuted),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 36, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Try again',
            variant: AppButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final int rank;
  final MealSuggestionDto suggestion;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.rank,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RankBadge(rank: rank),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.itemName,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${suggestion.restaurantName} · ${suggestion.category}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  suggestion.reason,
                  style: AppTypography.bodyMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatLei(suggestion.price),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text('${suggestion.calories.round()} kcal',
                  style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: AppTypography.caption.copyWith(
          color: AppColors.textOnDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
