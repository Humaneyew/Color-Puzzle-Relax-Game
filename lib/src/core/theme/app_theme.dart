import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const String _fontFamily = 'SF Pro';

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFd4a373),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFEFD5A9),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF3C2F2F),
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        fontFamily: _fontFamily,
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        useMaterial3: true,
      );
}
