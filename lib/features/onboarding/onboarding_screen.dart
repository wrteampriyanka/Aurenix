import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/onboarding/controllers/onboarding_controller.dart';
import 'package:aurenix/features/onboarding/widgets/integration_hub.dart';
import 'package:aurenix/features/onboarding/widgets/wave_orb.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
      body: AppBackground(
        // The orb lights the top here, so keep the softer fade.
        deepTop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const WaveOrb(size: 238),
                          const IntegrationHub(),
                          const SizedBox(height: 28),
                          _FadeSlideIn(
                            child: SizedBox(
                              width: 320,
                              child: Column(
                                children: [
                                  AppText(
                                    AppStrings.onboardingTitle.tr,
                                    fontSize: AppFontSize.headline,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                    color: appColors.textNatural,
                                  ),
                                  const SizedBox(height: 10),
                                  AppText(
                                    AppStrings.onboardingSubtitle.tr,
                                    fontSize: AppFontSize.body,
                                    textAlign: TextAlign.center,
                                    color: appColors.textBody,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: AppStrings.getStarted.tr,
                  onPressed: controller.onGetStarted,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
