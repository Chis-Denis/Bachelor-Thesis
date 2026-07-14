import 'package:flutter/material.dart';

import '../../domain/issues/complaint_image_ref.dart';
import '../common/app_scope.dart';
import '../design/design.dart';
import 'complaint_image.dart';
import 'report_issue_view_model.dart';

class ReportIssueScreen extends StatefulWidget {
  final int restaurantId;
  final int? orderId;
  final String restaurantName;

  const ReportIssueScreen({
    super.key,
    required this.restaurantId,
    required this.orderId,
    required this.restaurantName,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _description = TextEditingController();
  late final ReportIssueViewModel _viewModel;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.of(context);
    _viewModel = ReportIssueViewModel(
      scope.reportIssue,
      scope.complaintPhotoCapture,
    )..addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _busy => _viewModel.isSubmitting || _viewModel.isCapturing;

  Future<void> _takePhoto() => _captureWith(_viewModel.takePhoto);

  Future<void> _pickFromGallery() => _captureWith(_viewModel.pickFromGallery);

  Future<void> _captureWith(Future<String?> Function() action) async {
    final ref = await action();
    if (!mounted) return;
    if (ref != null) {
      setState(() => _selectedImage = ref);
      return;
    }
    final error = _viewModel.errorMessage;
    if (error != null) {
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _submit() async {
    final image = _selectedImage;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a photo of the problem')),
      );
      return;
    }
    final success = await _viewModel.submit(
      restaurantId: widget.restaurantId,
      orderId: widget.orderId,
      description: _description.text,
      imageRef: image,
    );
    if (!mounted) return;
    if (!success) {
      final message = _viewModel.errorMessage ?? 'Could not submit your report';
      _viewModel.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted to the restaurant')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context).complaintImageStore;
    final refs = store.demoImageRefs;
    final saving = _viewModel.isSubmitting;
    final hasCapturedPhoto =
        _selectedImage != null && ComplaintImageRef.isFile(_selectedImage!);
    return AppScaffold(
      title: 'Report a problem',
      showBack: true,
      maxWidth: AppSizes.formMaxWidth,
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text('Order from ${widget.restaurantName}',
              style: AppTypography.bodyMuted),
          const SizedBox(height: AppSpacing.lg),
          Text('Attach a photo', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Take a photo of the problem, choose one from your gallery, or pick '
            'a demo photo below.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _takePhoto,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (hasCapturedPhoto) ...[
            const SizedBox(height: AppSpacing.md),
            _CapturedPreview(imageRef: _selectedImage!),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Or pick a demo photo', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.xs),
          Text('The demo photos exercise the forensic check.',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: refs.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final ref = refs[index];
                return _ImageOption(
                  imageRef: ref,
                  label: store.labelFor(ref),
                  selected: _selectedImage == ref,
                  onTap:
                      _busy ? null : () => setState(() => _selectedImage = ref),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What went wrong?', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _description,
            label: 'Description',
            enabled: !saving,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Submit report',
            onPressed: _submit,
            isLoading: saving,
          ),
        ],
      ),
    );
  }
}

class _CapturedPreview extends StatelessWidget {
  final String imageRef;

  const _CapturedPreview({required this.imageRef});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: AppRadii.all12,
            border: Border.all(color: AppColors.accent, width: 2),
          ),
          child: ClipRRect(
            borderRadius: AppRadii.all12,
            child: ComplaintImage(
              imageRef: imageRef,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
            Text('Your photo is ready to submit', style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

class _ImageOption extends StatelessWidget {
  final String imageRef;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ImageOption({
    required this.imageRef,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.all8,
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: AppRadii.all8,
              child: Image.asset(imageRef,
                  width: 96, height: 78, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
