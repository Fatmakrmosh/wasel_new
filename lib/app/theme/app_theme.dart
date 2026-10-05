import 'package:flutter/material.dart';

import 'wasel_colors.dart';

class WaselTheme {
  WaselTheme._();

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: WaselColors.background,
    colorScheme: const ColorScheme.dark(
      primary: WaselColors.primary,
      secondary: WaselColors.primary,
      surface: WaselColors.surface,
      error: WaselColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: WaselColors.background,
      foregroundColor: WaselColors.textPrimary,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: WaselColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: WaselColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WaselColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WaselColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: WaselColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: WaselColors.primary,
          width: 1.5,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WaselColors.primary,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 54),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}
