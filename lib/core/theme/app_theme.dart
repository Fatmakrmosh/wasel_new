import 'package:flutter/material.dart';

import '../../app/theme/wasel_colors.dart';

class AppColors {
  static const background = WaselColors.background;
  static const surface = WaselColors.surface;
  static const lime = WaselColors.primary;
  static const text = WaselColors.textPrimary;
  static const muted = WaselColors.textSecondary;
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WaselColors.background,
        colorScheme: const ColorScheme.dark(
          primary: WaselColors.primary,
          secondary: WaselColors.primary,
          surface: WaselColors.surface,
          error: WaselColors.error,
        ),
        useMaterial3: true,
      );
}
