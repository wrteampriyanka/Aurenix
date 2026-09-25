import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/app_background.dart';
import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/integration_hub.dart';
import '../widgets/wave_orb.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
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
                                  CustomText(
                                    'onboarding_title'.tr,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                    color: context.color.textNatural,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomText(
                                    'onboarding_subtitle'.tr,
                                    fontSize: 16,
                                    textAlign: TextAlign.center,
                                    color: context.color.textBody,
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
                const SizedBox(height: 16),
                AppButton(
                  label: 'get_started'.tr,
                  onPressed: controller.onGetStarted,
                ),
                const SizedBox(height: 16),
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
