import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Vazir',
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Vazir'),
      displayMedium: TextStyle(fontFamily: 'Vazir'),
      displaySmall: TextStyle(fontFamily: 'Vazir'),
      headlineLarge: TextStyle(fontFamily: 'Vazir'),
      headlineMedium: TextStyle(fontFamily: 'Vazir'),
      headlineSmall: TextStyle(fontFamily: 'Vazir'),
      titleLarge: TextStyle(fontFamily: 'Vazir'),
      titleMedium: TextStyle(fontFamily: 'Vazir'),
      titleSmall: TextStyle(fontFamily: 'Vazir'),
      bodyLarge: TextStyle(fontFamily: 'Vazir'),
      bodyMedium: TextStyle(fontFamily: 'Vazir'),
      bodySmall: TextStyle(fontFamily: 'Vazir'),
      labelLarge: TextStyle(fontFamily: 'Vazir'),
      labelMedium: TextStyle(fontFamily: 'Vazir'),
      labelSmall: TextStyle(fontFamily: 'Vazir'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Vazir',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    fontFamily: 'Vazir',
  );
}
