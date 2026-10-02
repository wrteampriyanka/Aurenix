import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import 'custom_text.dart';

/// Light pill button with a leading brand logo (e.g. Google, GitHub).
class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    super.key,
    required this.label,
    required this.logo,
    this.onPressed,
    this.height = 52,
  });

  final String label;

  /// SVG asset path, see `AppAssets`.
  final String logo;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.socialButtonFill,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(logo, width: 20, height: 20),
              const SizedBox(width: 12),
              Flexible(
                child: CustomText(
                  label,
                  maxLines: 1,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.color.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
