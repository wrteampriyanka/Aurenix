import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/app_button.dart';
import '../widgets/app_plain_background.dart';
import '../widgets/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/validators.dart';
import 'controllers/reset_password_controller.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppPlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBackHeader(title: 'reset_password_title'.tr),
              Divider(height: 1, color: context.color.strokeDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _ResetForm(controller: controller),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: AppButton(
                  label: 'submit_new_password'.tr,
                  icon: null,
                  height: 52,
                  onPressed: controller.onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetForm extends StatelessWidget {
  const _ResetForm({required this.controller});

  final ResetPasswordController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => AppTextField(
                controller: controller.passwordController,
                hint: 'create_password_hint'.tr,
                prefixIcon: PhosphorIconsRegular.lockSimple,
                obscureText: controller.isPasswordHidden.value,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
                suffix: _VisibilityToggle(
                  hidden: controller.isPasswordHidden.value,
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppTextField(
                controller: controller.confirmController,
                hint: 'confirm_password_hint'.tr,
                prefixIcon: PhosphorIconsRegular.lockSimple,
                obscureText: controller.isConfirmHidden.value,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: controller.validateConfirm,
                onFieldSubmitted: (_) => controller.onSubmit(),
                suffix: _VisibilityToggle(
                  hidden: controller.isConfirmHidden.value,
                  onPressed: controller.toggleConfirmVisibility,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.hidden, required this.onPressed});

  final bool hidden;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        hidden ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
        size: 22,
        color: context.color.textNatural,
      ),
    );
  }
}
