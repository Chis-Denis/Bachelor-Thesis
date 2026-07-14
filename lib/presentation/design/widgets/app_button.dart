import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
            ),
          )
        : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.primary =>
        FilledButton(onPressed: effectiveOnPressed, child: child),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: effectiveOnPressed, child: child),
      AppButtonVariant.text =>
        TextButton(onPressed: effectiveOnPressed, child: child),
    };

    if (variant == AppButtonVariant.text) {
      return Align(alignment: Alignment.center, child: button);
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
