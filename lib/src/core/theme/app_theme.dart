import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const String _fontFamily = 'SF Pro';

  static const Color _backgroundColor = Color(0xFFEFD5A9);
  static const Color _appBarColor = Color(0xFFF8E4C5);
  static const Color _counterPanelColor = Color(0xFFF3D8B4);
  static const Color _primaryTextColor = Color(0xFF3C2F2F);
  static const Color _accentColor = Color(0xFFD4A373);
  static const Color _accentDark = Color(0xFFB5835A);

  static ThemeData get light => ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: _accentColor,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFF0CBB2),
          onPrimaryContainer: _primaryTextColor,
          secondary: _accentDark,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFF5D3B5),
          onSecondaryContainer: _primaryTextColor,
          tertiary: Color(0xFF8C5C2C),
          onTertiary: Colors.white,
          tertiaryContainer: _counterPanelColor,
          onTertiaryContainer: _primaryTextColor,
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          background: _backgroundColor,
          onBackground: _primaryTextColor,
          surface: _appBarColor,
          onSurface: _primaryTextColor,
          surfaceVariant: Color(0xFFE7D6C4),
          onSurfaceVariant: Color(0xFF52443A),
          outline: Color(0xFFA78976),
          outlineVariant: Color(0xFFD9C4B0),
          shadow: Color(0x33000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF4F4036),
          onInverseSurface: Color(0xFFF8E4C5),
          inversePrimary: Color(0xFF8E4F20),
          surfaceTint: _accentColor,
        ),
        scaffoldBackgroundColor: _backgroundColor,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: _appBarColor,
          foregroundColor: _primaryTextColor,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(
          color: _primaryTextColor,
          size: 24,
        ),
        cardTheme: const CardThemeData(
          color: _counterPanelColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        fontFamily: _fontFamily,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _primaryTextColor,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _primaryTextColor,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _primaryTextColor,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _primaryTextColor,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: _primaryTextColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _primaryTextColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _primaryTextColor,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _primaryTextColor,
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _primaryTextColor,
          ),
          labelMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: _primaryTextColor,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return _accentColor.withOpacity(0.4);
              }
              if (states.contains(MaterialState.pressed)) {
                return _accentDark;
              }
              return _accentColor;
            }),
            foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
            textStyle: const MaterialStatePropertyAll<TextStyle>(
              TextStyle(
                fontFamily: _fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStatePropertyAll(
              BorderSide(color: _primaryTextColor.withOpacity(0.6), width: 1.5),
            ),
            foregroundColor: const MaterialStatePropertyAll<Color>(_primaryTextColor),
            overlayColor: MaterialStatePropertyAll(_accentColor.withOpacity(0.1)),
            textStyle: const MaterialStatePropertyAll<TextStyle>(
              TextStyle(
                fontFamily: _fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
              ),
            ),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const MaterialStatePropertyAll<Color>(_primaryTextColor),
            overlayColor: MaterialStatePropertyAll(_accentColor.withOpacity(0.12)),
            textStyle: const MaterialStatePropertyAll<TextStyle>(
              TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
        useMaterial3: true,
      );
}
