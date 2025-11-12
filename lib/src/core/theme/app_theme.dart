import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFd4a373),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5E5C0),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF3C2F2F),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        useMaterial3: true,
      );
}
