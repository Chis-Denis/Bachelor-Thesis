import 'package:flutter/material.dart';

import '../../application/issues/evidence_item_dto.dart';
import '../../application/issues/issue_dto.dart';
import '../../application/issues/photo_check_result_dto.dart';
import '../common/app_scope.dart';
import '../common/formatters/date_format.dart';
import '../design/design.dart';
import 'complaint_image.dart';
import 'issue_detail_view_model.dart';
import 'verdict_visuals.dart';

class IssueDetailScreen extends StatefulWidget {
  final IssueDto issue;

  const IssueDetailScreen({super.key, required this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late final IssueDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = IssueDetailViewModel(
      AppScope.of(context).checkIssuePhoto,
      widget.issue,
    )..addListener(_onChanged);
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
    final issue = widget.issue;
    final result = _viewModel.result;
    return AppScaffold(
      title: 'Report',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadii.all12,
            child: ComplaintImage(
              imageRef: issue.imageRef,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            issue.description.isEmpty
                ? 'No description provided.'
                : issue.description,
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reported by ${issue.reporterUsername} · ${formatDateRelative(issue.createdAt)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (result != null)
            _ResultView(result: result)
          else
            _CheckPrompt(
              isChecking: _viewModel.isChecking,
              onCheck: _viewModel.runCheck,
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _CheckPrompt extends StatelessWidget {
  final bool isChecking;
  final VoidCallback onCheck;

  const _CheckPrompt({required this.isChecking, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.shield_outlined,
              size: 32, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text('Authenticity check', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Run the forensic + AI analysis to see whether this photo is a '
            'genuine camera photo, edited, or AI-generated.',
            style: AppTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Run authenticity check',
            onPressed: onCheck,
            isLoading: isChecking,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final PhotoCheckResultDto result;

  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = VerdictVisuals.color(result.verdict);
    final percent = (result.confidence * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadii.all12,
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(VerdictVisuals.icon(result.verdict), size: 28, color: color),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.verdict.label,
                        style: AppTypography.subheading.copyWith(color: color)),
                    Text('$percent% confidence', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Evidence', style: AppTypography.subheading),
        const SizedBox(height: AppSpacing.sm),
        ...result.evidence.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _EvidenceRow(item: item),
            )),
        if (result.aiSummary.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _RecommendationCard(text: result.aiSummary),
        ],
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String text;

  const _RecommendationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.all12,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assistant_outlined,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI recommendation',
                    style: AppTypography.caption
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(text, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final EvidenceItemDto item;

  const _EvidenceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = VerdictVisuals.signalColor(item.signal);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(VerdictVisuals.signalIcon(item.signal), size: 18, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.detail, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
