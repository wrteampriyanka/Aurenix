import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../services/connected_apps_service.dart';

/// Draws an [IntegrationApp]'s SVG or PNG logo at [size].
class IntegrationAppLogo extends StatelessWidget {
  const IntegrationAppLogo({super.key, required this.app, required this.size});

  final IntegrationApp app;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!app.logo.endsWith('.svg')) {
      return Image.asset(app.logo, width: size, height: size);
    }
    return SvgPicture.asset(
      app.logo,
      width: size,
      height: size,
      colorFilter: app.tintLogo
          ? ColorFilter.mode(context.color.textNatural, BlendMode.srcIn)
          : null,
    );
  }
}
