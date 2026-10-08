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
import 'package:aurenix/features/register/controllers/register_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
                      _RegisterForm(controller: controller),
                      const SizedBox(height: AppSpacing.xxl),
                      const AppOrDivider(),
                      const SizedBox(height: AppSpacing.xxl),
                      AppSocialButton(
                        label: AppStrings.continueWithGoogle.tr,
                        logo: AppAssets.googleLogo,
                        onPressed: controller.onGoogleSignUp,
                      ),
                      const SizedBox(height: 14),
                      AppSocialButton(
                        label: AppStrings.continueWithGithub.tr,
                        logo: AppAssets.githubLogo,
                        onPressed: controller.onGithubSignUp,
                      ),
                      const SizedBox(height: 28),
                      _SignInPrompt(controller: controller),
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
          AppStrings.registerTitle.tr,
          fontSize: AppFontSize.title,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: appColors.textNatural,
        ),
        const SizedBox(height: 10),
        AppText(
          AppStrings.registerSubtitle.tr,
          fontSize: AppFontSize.body,
          textAlign: TextAlign.center,
          color: appColors.textBody,
        ),
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nameController,
              label: AppStrings.fieldNameLabel.tr,
              hint: AppStrings.nameHint.tr,
              prefixIcon: PhosphorIconsRegular.userCircle,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
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
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.required,
              onFieldSubmitted: (_) => controller.onCreateAccount(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppStrings.createAccount.tr,
              height: 52,
              onPressed: controller.onCreateAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.controller});

  final RegisterController controller;

  @override
  Widget build(BuildContext context) {
    return AppText.rich(
      TextSpan(
        children: [
          TextSpan(text: AppStrings.haveAccount.tr),
          TextSpan(
            text: AppStrings.signIn.tr,
            recognizer: controller.signInRecognizer,
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
