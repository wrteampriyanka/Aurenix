import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurenix/core/theme/app_colors.dart';

/// Paints the system bars to match the screen behind them.
///
/// Every screen's background widget wraps itself in this instead of repeating
/// the [SystemUiOverlayStyle] literal. The app is dark-only, so the icons are
/// always light; only the navigation bar's colour varies, and then only on the
/// splash screen, which is blue rather than the usual dark base.
class AppSystemUiOverlay extends StatelessWidget {
  const AppSystemUiOverlay({
    super.key,
    required this.child,
    this.navigationBarColor,
  });

  final Widget child;

  /// Defaults to the dark base every other screen paints.
  final Color? navigationBarColor;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            navigationBarColor ?? appColors.backgroundBase,
        systemNavigationBarIconBrightness: Brightness.light,
        // Android otherwise draws a translucent scrim behind the nav bar,
        // which reads as a lighter strip against the dark scaffold.
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
