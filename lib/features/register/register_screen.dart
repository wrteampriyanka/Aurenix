import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/widgets/app_background.dart';
import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_social_button.dart';
import 'package:aurenix/features/widgets/app_terms_footer.dart';
import 'package:aurenix/features/widgets/app_text_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/features/widgets/or_divider.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/features/register/controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
                      const SizedBox(height: 24),
                      const Spacer(),
                      _Header(),
                      const SizedBox(height: 28),
                      _RegisterForm(controller: controller),
                      const SizedBox(height: 24),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      AppSocialButton(
                        label: 'continue_with_google'.tr,
                        logo: AppAssets.googleLogo,
                        onPressed: controller.onGoogleSignUp,
                      ),
                      const SizedBox(height: 14),
                      AppSocialButton(
                        label: 'continue_with_github'.tr,
                        logo: AppAssets.githubLogo,
                        onPressed: controller.onGithubSignUp,
                      ),
                      const SizedBox(height: 28),
                      _SignInPrompt(controller: controller),
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
          'register_title'.tr,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: context.color.textNatural,
        ),
        const SizedBox(height: 10),
        CustomText(
          'register_subtitle'.tr,
          fontSize: 16,
          textAlign: TextAlign.center,
          color: context.color.textBody,
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
              hint: 'name_hint'.tr,
              prefixIcon: PhosphorIconsRegular.userCircle,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.emailController,
              hint: 'email_hint'.tr,
              prefixIcon: PhosphorIconsRegular.envelopeSimple,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppTextField(
                controller: controller.passwordController,
                hint: 'password_hint'.tr,
                prefixIcon: PhosphorIconsRegular.lockSimpleOpen,
                obscureText: controller.isPasswordHidden.value,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.required,
                onFieldSubmitted: (_) => controller.onCreateAccount(),
                suffix: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? PhosphorIconsRegular.eyeSlash
                        : PhosphorIconsRegular.eye,
                    size: 22,
                    color: context.color.textNatural,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'create_account'.tr,
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
    return CustomText(
      '',
      fontSize: 14,
      textAlign: TextAlign.center,
      color: context.color.textBody,
      textSpan: TextSpan(
        children: [
          TextSpan(text: 'have_account'.tr),
          TextSpan(
            text: 'sign_in'.tr,
            recognizer: controller.signInRecognizer,
            style: TextStyle(
              color: context.color.textNatural,
              decoration: TextDecoration.underline,
              decorationColor: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
