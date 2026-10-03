import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/ui/screens/widgets/app_background.dart';
import 'package:aurenix/ui/screens/widgets/app_button.dart';
import 'package:aurenix/ui/screens/widgets/app_social_button.dart';
import 'package:aurenix/ui/screens/widgets/app_terms_footer.dart';
import 'package:aurenix/ui/screens/widgets/app_text_field.dart';
import 'package:aurenix/ui/screens/widgets/custom_text.dart';
import 'package:aurenix/ui/screens/widgets/or_divider.dart';
import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/ui/screens/login/controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

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
                      _LoginForm(controller: controller),
                      const SizedBox(height: 24),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      AppSocialButton(
                        label: 'continue_with_google'.tr,
                        logo: AppAssets.googleLogo,
                        onPressed: controller.onGoogleLogin,
                      ),
                      const SizedBox(height: 14),
                      AppSocialButton(
                        label: 'continue_with_github'.tr,
                        logo: AppAssets.githubLogo,
                        onPressed: controller.onGithubLogin,
                      ),
                      const SizedBox(height: 28),
                      _RegisterPrompt(controller: controller),
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
          'login_title'.tr,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: context.color.textNatural,
        ),
        const SizedBox(height: 10),
        CustomText(
          'login_subtitle'.tr,
          fontSize: 16,
          textAlign: TextAlign.center,
          color: context.color.textBody,
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
                autofillHints: const [AutofillHints.password],
                validator: Validators.required,
                onFieldSubmitted: (_) => controller.onLogin(),
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
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: controller.onForgotPassword,
                child: CustomText(
                  'forgot_password'.tr,
                  fontSize: 14,
                  showUnderline: true,
                  color: context.color.textBody,
                  underlineOrLineColor: context.color.textBody,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'continue_login'.tr,
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
    return CustomText(
      '',
      fontSize: 14,
      textAlign: TextAlign.center,
      color: context.color.textBody,
      textSpan: TextSpan(
        children: [
          TextSpan(text: 'no_account'.tr),
          TextSpan(
            text: 'register_now'.tr,
            recognizer: controller.registerRecognizer,
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
