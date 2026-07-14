import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final double maxWidth;
  final EdgeInsets padding;

  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    this.showBack = false,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.bottomBar,
    this.maxWidth = AppSizes.contentMaxWidth,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: body),
      ),
    );

    final hasAppBar = title != null || showBack || leading != null;

    final Widget? resolvedLeading = leading ??
        (showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
              )
            : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: hasAppBar
          ? AppBar(
              leading: resolvedLeading,
              automaticallyImplyLeading: resolvedLeading != null,
              title: title == null ? null : Text(title!),
              actions: actions,
            )
          : null,
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
    );
  }
}
