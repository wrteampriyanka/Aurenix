import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_system_ui_overlay.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/constants/app_constants.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/splash/controllers/splash_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSystemUiOverlay(
      navigationBarColor: appColors.primary,
      child: Scaffold(
        backgroundColor: appColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.appIcon,
                width: 88,
                color: appColors.iconOnPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                AppConstants.appName,
                fontSize: AppFontSize.title,
                fontWeight: FontWeight.w600,
                color: appColors.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
