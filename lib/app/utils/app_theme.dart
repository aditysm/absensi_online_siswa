import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.lightText),
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.lightText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.lightTextLight, fontSize: 12),
      titleLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold),
      labelLarge:
          TextStyle(color: AppColors.lightPrimary, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      margin: const EdgeInsets.all(8),
    ),
    dividerColor: AppColors.lightBorder,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightTextInverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackgroundAlt,
      hintStyle: const TextStyle(color: AppColors.lightTextLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightBorder),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      primaryContainer: AppColors.lightPrimaryVariant,
      surface: AppColors.lightSurface,
      onPrimary: AppColors.lightTextInverse,
      onSurface: AppColors.lightText,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightTextInverse,
      error: AppColors.colorError,
      onError: AppColors.lightTextInverse,
    ),
  );

 static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackgroundAlt,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkText),
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.darkText, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.darkTextLight, fontSize: 12),
      titleLarge: TextStyle(
          color: AppColors.darkText, fontSize: 20, fontWeight: FontWeight.bold),
      labelLarge:
          TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.all(8),
    ),
    dividerColor: AppColors.darkBorder,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkTextInverse,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBackgroundAlt,
      hintStyle: const TextStyle(color: AppColors.darkTextLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.darkBorder),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      primaryContainer: AppColors.darkPrimaryVariant,
      surface: AppColors.darkSurface,
      onPrimary: AppColors.darkTextInverse,
      onSurface: AppColors.darkText,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkTextInverse,
      error: AppColors.colorError,
      onError: AppColors.darkTextInverse,
    ),
  );
}
