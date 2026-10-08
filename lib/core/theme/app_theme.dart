import 'package:flutter/material.dart';

import 'package:aurenix/core/theme/app_colors.dart';

/// The app's only theme.
///
/// Aurenix is dark-only: there is no light theme and the OS appearance
/// setting is ignored (`themeMode: ThemeMode.dark` in [MyApp]). Anything
/// Material derives from the theme — dialogs, SnackBar, bottom sheets,
/// text selection, pickers, the iOS keyboard — reads these values, so they
/// must stay dark.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Space Grotesk';

  static const AppColors _colors = AppColors.instance;

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: _colors.backgroundPrimary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _colors.primary,
      primary: _colors.primary,
      secondary: _colors.secondary,
      error: _colors.error,
      surface: _colors.backgroundPrimary,
      onSurface: _colors.textPrimary,
      brightness: Brightness.dark,
    ),
  );
}
