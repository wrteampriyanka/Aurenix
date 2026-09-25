import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_text_field.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/validators.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: _PlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TopBar(),
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

/// Plain dark screen with a soft glow behind the status bar, as in the design.
class _PlainBackground extends StatelessWidget {
  const _PlainBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.05),
            radius: 0.55,
            colors: [
              context.color.topGlow.withValues(alpha: 0.7),
              context.color.backgroundBase,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Material(
            color: context.color.inputFill,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: Get.back,
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  PhosphorIconsRegular.caretLeft,
                  size: 20,
                  color: context.color.textNatural,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CustomText(
            'reset_password_title'.tr,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: context.color.textNatural,
          ),
        ],
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
