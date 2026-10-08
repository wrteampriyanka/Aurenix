import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';

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
      color: appColors.socialButtonFill,
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
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: AppText(
                  label,
                  maxLines: 1,
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w500,
                  color: appColors.textOnLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
