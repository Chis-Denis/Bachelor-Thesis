import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? borderColor;
  final double borderWidth;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.all8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.all8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadii.all8,
            border: Border.fromBorderSide(
              BorderSide(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              ),
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
