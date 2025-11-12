import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFF5E9D7);
  const surface = Color(0xFFFFF5E7);
  const primary = Color(0xFF3D7FA8);
  const secondary = Color(0xFFE47D74);
  const textColor = Color(0xFF2F2A25);
  final baseTextTheme = Typography.blackMountainView.apply(
    fontFamily: 'Roboto',
    bodyColor: textColor,
    displayColor: textColor,
  );

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      background: background,
      onBackground: textColor,
      surface: surface,
      onSurface: textColor,
      surfaceVariant: const Color(0xFFF0DFCB),
      onSurfaceVariant: textColor.withOpacity(0.75),
      outline: textColor.withOpacity(0.2),
      outlineVariant: textColor.withOpacity(0.12),
      inverseSurface: const Color(0xFF214C64),
      onInverseSurface: Colors.white,
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.35),
      tertiary: const Color(0xFFE5B973),
      onTertiary: const Color(0xFF3F2E11),
      tertiaryContainer: const Color(0xFFFFE3BC),
      onTertiaryContainer: const Color(0xFF4C3A15),
      primaryContainer: const Color(0xFFE0F1FA),
      onPrimaryContainer: const Color(0xFF0F3A51),
      secondaryContainer: const Color(0xFFFFDDD6),
      onSecondaryContainer: const Color(0xFF4C1F1A),
    ),
    textTheme: baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        height: 1.4,
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      shadowColor: Colors.black.withOpacity(0.06),
    ),
    iconTheme: const IconThemeData(color: textColor),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2F4858),
      contentTextStyle: baseTextTheme.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: textColor.withOpacity(0.08),
      thickness: 1,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: baseTextTheme.bodySmall?.copyWith(color: Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
    ),
  );
}
