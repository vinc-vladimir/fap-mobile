import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

ThemeData get lightTheme => _buildTheme(colorScheme: lightColorScheme);

ThemeData get darkTheme => _buildTheme(colorScheme: darkColorScheme);

ThemeData _buildTheme({required ColorScheme colorScheme}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: appTextTheme,
    scaffoldBackgroundColor: colorScheme.surface,

    // ── Input Decoration ─────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.containerPadding,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(color: vibrantCyan, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      labelStyle: appTextTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      hintStyle: appTextTheme.bodyMedium?.copyWith(
        color: colorScheme.outline.withValues(alpha: 0.5),
      ),
    ),

    // ── Elevated Button ──────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vibrantCyan,
        foregroundColor: colorScheme.onPrimaryContainer,
        textStyle: appTextTheme.displaySmall,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        elevation: 0,
      ),
    ),

    // ── Outlined Button ──────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        textStyle: appTextTheme.displaySmall,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
    ),
  );
}
