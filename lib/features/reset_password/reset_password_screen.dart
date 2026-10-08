import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/features/reset_password/controllers/reset_password_controller.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
      body: AppPlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBackHeader(title: AppStrings.resetPasswordTitle.tr),
              Divider(height: 1, color: appColors.strokeDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _ResetForm(controller: controller),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: AppButton(
                  label: AppStrings.submitNewPassword.tr,
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
            AppTextField(
              controller: controller.passwordController,
              label: AppStrings.fieldNewPasswordLabel.tr,
              hint: AppStrings.createPasswordHint.tr,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: controller.confirmController,
              label: AppStrings.fieldConfirmPasswordLabel.tr,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: controller.validateConfirm,
              onFieldSubmitted: (_) => controller.onSubmit(),
            ),
          ],
        ),
      ),
    );
  }
}
