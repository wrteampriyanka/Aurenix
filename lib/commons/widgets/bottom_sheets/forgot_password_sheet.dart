import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/features/login/controllers/login_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Bottom sheet asking for the account email before starting verification.
/// Plain dark background, as in the design.
class ForgotPasswordSheet extends GetView<LoginController> {
  const ForgotPasswordSheet({super.key});

  static const double _radius = 28;

  static Future<void> show() => Get.bottomSheet(
    const ForgotPasswordSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    // Get.bottomSheet already lifts the sheet above the keyboard.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(_radius)),
      child: Stack(
        children: [
          // Sized by the content below, so the background fits the sheet.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: appColors.backgroundBase,
                border: Border(top: BorderSide(color: appColors.strokeDark)),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: _Content(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.forgotFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FadeSlideIn(
            order: 0,
            child: SvgPicture.asset(AppAssets.forgotPassword, height: 150),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FadeSlideIn(
            order: 1,
            child: Column(
              children: [
                AppText(
                  AppStrings.forgotPasswordTitle.tr,
                  fontSize: AppFontSize.sheetTitle,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  color: appColors.textNatural,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  AppStrings.forgotPasswordSubtitle.tr,
                  fontSize: AppFontSize.chat,
                  textAlign: TextAlign.center,
                  color: appColors.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FadeSlideIn(
            order: 2,
            child: AppTextField(
              controller: controller.forgotEmailController,
              label: AppStrings.fieldEmailLabel.tr,
              hint: AppStrings.emailHint.tr,
              prefixIcon: PhosphorIconsRegular.envelopeSimple,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              onFieldSubmitted: (_) => controller.onStartVerification(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FadeSlideIn(
            order: 3,
            child: AppButton(
              label: AppStrings.startVerification.tr,
              icon: PhosphorIconsRegular.shieldCheck,
              height: 52,
              onPressed: controller.onStartVerification,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades and slides [child] up as the sheet opens, staggered by [order].
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({required this.order, required this.child});

  final int order;
  final Widget child;

  static const _step = 90;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + order * _step),
      curve: Interval(
        order * _step / (450 + order * _step),
        1,
        curve: Curves.easeOutCubic,
      ),
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
