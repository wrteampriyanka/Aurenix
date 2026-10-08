import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_otp_field.dart';
import 'package:aurenix/commons/widgets/app_terms_footer.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/otp/controllers/otp_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class OtpScreen extends GetView<OtpController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
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
                      const SizedBox(height: AppSpacing.xxl),
                      AppOtpField(
                        controller: controller.codeController,
                        focusNode: controller.codeFocusNode,
                        onCompleted: (_) => controller.onContinue(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: AppStrings.continueKey.tr,
                        icon: null,
                        height: 44,
                        onPressed: controller.onContinue,
                      ),
                      const SizedBox(height: 28),
                      _ResendPrompt(controller: controller),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.xxxl),
                      AppTermsFooter(
                        termsRecognizer: controller.termsRecognizer,
                        privacyRecognizer: controller.privacyRecognizer,
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
        AppText(
          AppStrings.otpTitle.tr,
          fontSize: AppFontSize.title,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: appColors.textNatural,
        ),
        const SizedBox(height: 10),
        AppText(
          AppStrings.otpSubtitle.trParams({
            'count': '${OtpController.codeLength}',
          }),
          fontSize: AppFontSize.body,
          textAlign: TextAlign.center,
          color: appColors.textBody,
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
      color: appColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: appColors.primary,
    );

    return Obx(
      () => AppText.rich(
        controller.canResend
            ? TextSpan(
                text: AppStrings.resendCode.tr,
                recognizer: controller.resendRecognizer,
                style: linkStyle,
              )
            : TextSpan(
                children: [
                  TextSpan(text: AppStrings.resendCodeIn.tr),
                  TextSpan(text: controller.resendCountdown, style: linkStyle),
                ],
              ),
        fontSize: AppFontSize.label,
        textAlign: TextAlign.center,
        color: appColors.textBody,
      ),
    );
  }
}
