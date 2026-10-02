import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_otp_field.dart';
import '../widgets/app_terms_footer.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/otp/controllers/otp_controller.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppBackground(
        gridOverContent: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      _Header(),
                      const SizedBox(height: 24),
                      AppOtpField(
                        controller: controller.codeController,
                        focusNode: controller.codeFocusNode,
                        length: OtpController.codeLength,
                        onCompleted: (_) => controller.onContinue(),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'continue'.tr,
                        icon: null,
                        height: 44,
                        onPressed: controller.onContinue,
                      ),
                      const SizedBox(height: 28),
                      _ResendPrompt(controller: controller),
                      const Spacer(),
                      const SizedBox(height: 32),
                      AppTermsFooter(
                        termsRecognizer: controller.termsRecognizer,
                        privacyRecognizer: controller.privacyRecognizer,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          'otp_title'.tr,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: context.color.textNatural,
        ),
        const SizedBox(height: 10),
        CustomText(
          'otp_subtitle'.trParams({'count': '${OtpController.codeLength}'}),
          fontSize: 16,
          textAlign: TextAlign.center,
          color: context.color.textBody,
        ),
      ],
    );
  }
}

/// "Resend Code in - 02:00" while counting down, then a "Resend Code" link.
class _ResendPrompt extends StatelessWidget {
  const _ResendPrompt({required this.controller});

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: context.color.primary,
      decoration: TextDecoration.underline,
      decorationColor: context.color.primary,
    );

    return Obx(
      () => CustomText(
        '',
        fontSize: 14,
        textAlign: TextAlign.center,
        color: context.color.textBody,
        textSpan: controller.canResend
            ? TextSpan(
                text: 'resend_code'.tr,
                recognizer: controller.resendRecognizer,
                style: linkStyle,
              )
            : TextSpan(
                children: [
                  TextSpan(text: 'resend_code_in'.tr),
                  TextSpan(text: controller.resendCountdown, style: linkStyle),
                ],
              ),
      ),
    );
  }
}
