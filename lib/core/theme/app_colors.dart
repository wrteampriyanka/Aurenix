import 'package:flutter/material.dart';

/// App colours. Use in widgets as `context.color.primary`.
class AppColors {
  const AppColors._();

  static const AppColors instance = AppColors._();

  // Shades/primary/400
  final Color primary = const Color(0xFF2563EB);
  final Color secondary = const Color(0xFF10B981);
  final Color error = const Color(0xFFEF4444);

  final Color backgroundPrimary = const Color(0xFFFFFFFF);
  final Color backgroundSecondary = const Color(0xFFF9FAFB);

  final Color textPrimary = const Color(0xFF111827);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color textOnPrimary = const Color(0xFFFFFFFF);

  final Color iconOnPrimary = const Color(0xFFEFF6FF);

  // Texts/Natural
  final Color textNatural = const Color(0xFFECF2FD);
  // Texts/Body text
  final Color textBody = const Color(0xFF95A3C2);
  // Shades/primary/50
  final Color primaryShade50 = const Color(0xFFEFF6FF);

  // Primary button gradient highlight and border
  final Color buttonHighlight = const Color(0xFF7FA2F5);
  final Color buttonBorder = const Color(0xFF5A8AF2);

  // Dark screen background (AppBackground)
  final Color backgroundDark = const Color(0xFF0B0F19);
  final Color backgroundDarkSecondary = const Color(0xFF111827);
  final Color backgroundGlow = const Color(0xFF1D4ED8);
  final Color surfaceDark = const Color(0xFF1A1F2B);
  final Color strokeDark = const Color(0x1AFFFFFF);

  // Onboarding orb
  final Color orbLight = const Color(0xFF60A5FA);
  final Color orbDeep = const Color(0xFF1E40AF);
  final Color accentPurple = const Color(0xFF8B5CF6);
  final Color orbBright = const Color(0xFF1E9BFF);
  final Color orbBase = const Color(0xFF3B6FF5);
  final Color orbRing = const Color(0x33FFFFFF);

  // Onboarding integration hub
  final Color tileFill = const Color(0x0DFFFFFF);
  final Color tileFillHighlight = const Color(0x1AFFFFFF);
  final Color tileBorder = const Color(0x14FFFFFF);
  final Color platformIcon = const Color(0xFF5B6272);
  final Color appIconMuted = const Color(0xFFC9CDD4);
  final Color connectorLine = const Color(0x803B5BA5);
}

extension AppColorsContextX on BuildContext {
  AppColors get color => AppColors.instance;
}
