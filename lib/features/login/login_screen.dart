import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_social_button.dart';
import 'package:aurenix/commons/widgets/app_terms_footer.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/commons/widgets/app_or_divider.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/features/login/controllers/login_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

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
                      const SizedBox(height: AppSpacing.xxl),
                      const Spacer(),
                      _Header(),
                      const SizedBox(height: 28),
                      _LoginForm(controller: controller),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppOrDivider(),
                      const SizedBox(height: AppSpacing.xxl),
                      AppSocialButton(
                        label: AppStrings.continueWithGoogle.tr,
                        logo: AppAssets.googleLogo,
                        onPressed: controller.onGoogleLogin,
                      ),
                      const SizedBox(height: 14),
                      AppSocialButton(
                        label: AppStrings.continueWithGithub.tr,
                        logo: AppAssets.githubLogo,
                        onPressed: controller.onGithubLogin,
                      ),
                      const SizedBox(height: 28),
                      _RegisterPrompt(controller: controller),
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
          AppStrings.loginTitle.tr,
          fontSize: AppFontSize.title,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: appColors.textNatural,
        ),
        const SizedBox(height: 10),
        AppText(
          AppStrings.loginSubtitle.tr,
          fontSize: AppFontSize.body,
          textAlign: TextAlign.center,
          color: appColors.textBody,
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.emailController,
              label: AppStrings.fieldEmailLabel.tr,
              hint: AppStrings.emailHint.tr,
              prefixIcon: PhosphorIconsRegular.envelopeSimple,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: controller.passwordController,
              label: AppStrings.fieldPasswordLabel.tr,
              hint: AppStrings.passwordHint.tr,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.required,
              onFieldSubmitted: (_) => controller.onLogin(),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              // InkWell rather than GestureDetector: the splash then covers
              // the padded area, and the tap target is bigger than the text.
              child: InkWell(
                onTap: controller.onForgotPassword,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: AppText(
                    AppStrings.forgotPassword.tr,
                    fontSize: AppFontSize.label,
                    showUnderline: true,
                    color: appColors.textBody,
                    underlineOrLineColor: appColors.textBody,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: AppStrings.continueLogin.tr,
              height: 52,
              onPressed: controller.onLogin,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return AppText.rich(
      TextSpan(
        children: [
          TextSpan(text: AppStrings.noAccount.tr),
          TextSpan(
            text: AppStrings.registerNow.tr,
            recognizer: controller.registerRecognizer,
            style: TextStyle(
              color: appColors.textNatural,
              decoration: TextDecoration.underline,
              decorationColor: appColors.textNatural,
            ),
          ),
        ],
      ),
      fontSize: AppFontSize.label,
      textAlign: TextAlign.center,
      color: appColors.textBody,
    );
  }
}
