import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const background = Color(0xFFF0D9B5);
  const surface = Color(0xFFF7E7CE);
  const accent = Color(0xFF2C7FAE);
  const textColor = Color(0xFF3D3A33);
  final baseTextTheme = Typography.blackMountainView.apply(
    fontFamily: 'Roboto',
    bodyColor: textColor,
    displayColor: textColor,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFFDF7F5B),
      onSecondary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      background: background,
      onBackground: textColor,
      surface: surface,
      onSurface: textColor,
      outline: textColor.withOpacity(0.3),
      surfaceVariant: surface,
      onSurfaceVariant: textColor,
      inverseSurface: accent,
      onInverseSurface: Colors.white,
      outlineVariant: textColor.withOpacity(0.2),
      shadow: Colors.black.withOpacity(0.12),
      scrim: Colors.black.withOpacity(0.4),
      tertiary: const Color(0xFF9C6B9E),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE2D5EC),
      onTertiaryContainer: const Color(0xFF312236),
      primaryContainer: accent.withOpacity(0.2),
      onPrimaryContainer: accent,
      secondaryContainer: const Color(0xFFF4CBB2),
      onSecondaryContainer: const Color(0xFF3F2717),
    ),
    scaffoldBackgroundColor: background,
    dialogTheme: const DialogTheme(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    textTheme: baseTextTheme.copyWith(
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    ),
    iconTheme: const IconThemeData(color: textColor),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
