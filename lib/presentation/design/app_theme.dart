import 'package:flutter/material.dart';

import 'tokens/app_colors.dart';
import 'tokens/app_radii.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.textOnDark,
      secondary: AppColors.accentMuted,
      onSecondary: AppColors.textOnDark,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      error: AppColors.accentMuted,
      onError: AppColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      splashFactory: NoSplash.splashFactory,
      hoverColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surfaceMuted,
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.display,
        displaySmall: AppTypography.heading,
        headlineLarge: AppTypography.heading,
        headlineMedium: AppTypography.heading,
        headlineSmall: AppTypography.subheading,
        titleLarge: AppTypography.subheading,
        titleMedium: AppTypography.subheading,
        titleSmall: AppTypography.body,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.caption,
        labelSmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        shape: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 20,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        errorStyle: const TextStyle(
          color: AppColors.accentMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.textPrimary, width: 1.5),
        disabledBorder: _outline(AppColors.divider),
        errorBorder: _outline(AppColors.accentMuted),
        focusedErrorBorder: _outline(AppColors.accentMuted, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.accentDisabled,
          disabledForegroundColor: AppColors.textOnDark,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.all8),
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.accentDisabled,
          disabledForegroundColor: AppColors.textOnDark,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.all8),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.all8),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.button,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.all4),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.all12),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border, width: 1),
          borderRadius: AppRadii.all8,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.accent,
        contentTextStyle: TextStyle(
          color: AppColors.textOnDark,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: AppColors.textOnDark,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.all8),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.all12),
        titleTextStyle: AppTypography.subheading,
        contentTextStyle: AppTypography.body,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.surfaceSunken,
        circularTrackColor: AppColors.surfaceSunken,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textPrimary,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadii.all8,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
