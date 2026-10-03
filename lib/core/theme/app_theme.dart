import 'package:flutter/material.dart';

import 'package:aurenix/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Space Grotesk';

  static const AppColors _colors = AppColors.instance;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: _colors.backgroundPrimary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _colors.primary,
      primary: _colors.primary,
      secondary: _colors.secondary,
      error: _colors.error,
      surface: _colors.backgroundPrimary,
      brightness: Brightness.light,
    ),
  );
}
