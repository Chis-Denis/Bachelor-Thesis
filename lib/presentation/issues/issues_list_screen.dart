import 'package:flutter/material.dart';

import '../../application/issues/issue_dto.dart';
import '../../domain/issues/issue_status.dart';
import '../common/app_scope.dart';
import '../common/formatters/date_format.dart';
import '../design/design.dart';
import 'complaint_image.dart';
import 'issue_detail_screen.dart';
import 'issues_list_view_model.dart';
import 'verdict_visuals.dart';

class IssuesListScreen extends StatefulWidget {
  const IssuesListScreen({super.key});

  @override
  State<IssuesListScreen> createState() => _IssuesListScreenState();
}

class _IssuesListScreenState extends State<IssuesListScreen> {
  late final IssuesListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        IssuesListViewModel(AppScope.of(context).listMyRestaurantIssues)
          ..addListener(_onChanged);
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

  Future<void> _open(IssueDto issue) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
    );
    await _viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reported issues',
      showBack: true,
      maxWidth: AppSizes.contentMaxWidth,
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.issues.isEmpty
              ? _empty()
              : ListView.builder(
                  itemCount: _viewModel.issues.length,
                  itemBuilder: (context, index) {
                    final issue = _viewModel.issues[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _IssueRow(issue: issue, onTap: () => _open(issue)),
                    );
                  },
                ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 44, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No reports yet', style: AppTypography.subheading),
            const SizedBox(height: AppSpacing.xs),
            Text('Client complaints about your food will appear here.',
                style: AppTypography.bodyMuted, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final IssueDto issue;
  final VoidCallback onTap;

  const _IssueRow({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final result = issue.checkResult;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.all8,
            child: ComplaintImage(
              imageRef: issue.imageRef,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.description.isEmpty
                      ? 'No description'
                      : issue.description,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${issue.reporterUsername} · ${formatDateRelative(issue.createdAt)}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (result != null)
                  _VerdictChip(
                    label: result.verdict.label,
                    color: VerdictVisuals.color(result.verdict),
                    icon: VerdictVisuals.icon(result.verdict),
                  )
                else
                  _VerdictChip(
                    label: issue.status == IssueStatus.open
                        ? 'Not checked'
                        : 'Reviewed',
                    color: AppColors.textSecondary,
                    icon: Icons.schedule,
                  ),
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

class _VerdictChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _VerdictChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
