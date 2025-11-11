import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const baseColor = Color(0xFF0F172A);
  const accentColor = Color(0xFF38BDF8);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
      background: const Color(0xFFF8FAFC),
      primary: accentColor,
      secondary: const Color(0xFF94A3B8),
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    textTheme: Typography.blackMountainView.apply(
      fontFamily: 'Roboto',
      bodyColor: baseColor,
      displayColor: baseColor,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: baseColor,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
