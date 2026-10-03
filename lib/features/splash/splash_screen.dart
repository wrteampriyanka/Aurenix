import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/constants/app_constants.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/splash/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.color.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.appIcon,
                width: 88,
                color: context.color.iconOnPrimary,
              ),
              const SizedBox(height: 12),
              CustomText(
                AppConstants.appName,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: context.color.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
