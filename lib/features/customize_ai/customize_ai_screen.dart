import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_plain_background.dart';
import 'package:aurenix/features/widgets/app_settings_tile.dart';
import 'package:aurenix/features/widgets/app_text_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/customize_ai/controllers/customize_ai_controller.dart';

class CustomizeAiScreen extends GetView<CustomizeAiController> {
  const CustomizeAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'customize_ai_title'.tr,
      bottom: AppButton(
        label: 'customize_ai_save'.tr,
        icon: null,
        height: 52,
        fontSize: 16,
        onPressed: controller.onSave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppToggleCard(
              title: 'customize_ai_toggle_title'.tr,
              subtitle: 'customize_ai_toggle_subtitle'.tr,
              value: controller.isEnabled.value,
              onChanged: controller.onToggle,
            ),
          ),
          const SizedBox(height: 20),
          // The fields only apply while customization is on.
          Obx(
            () => IgnorePointer(
              ignoring: !controller.isEnabled.value,
              child: AnimatedOpacity(
                opacity: controller.isEnabled.value ? 1 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: _CustomizeForm(controller: controller),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppSettingsTile(
            icon: PhosphorIconsRegular.notebook,
            title: 'customize_ai_memories'.tr,
            subtitle: 'customize_ai_memories_subtitle'.tr,
            onTap: controller.onMemories,
          ),
        ],
      ),
    );
  }
}

class _CustomizeForm extends StatelessWidget {
  const _CustomizeForm({required this.controller});

  final CustomizeAiController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('customize_ai_personality'.tr),
        _PersonalityField(controller: controller),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.instructionsController,
          hint: 'customize_ai_instructions_hint'.tr,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _SectionLabel('customize_ai_your_info'.tr),
        AppTextField(
          controller: controller.nicknameController,
          hint: 'customize_ai_nickname_hint'.tr,
          prefixIcon: PhosphorIconsRegular.userCircle,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.nickname],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.occupationController,
          hint: 'customize_ai_occupation_hint'.tr,
          prefixIcon: PhosphorIconsRegular.briefcase,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.jobTitle],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: controller.aboutController,
          hint: 'customize_ai_about_hint'.tr,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomText(
        text,
        maxLines: 1,
        fontSize: 13,
        color: context.color.textBody,
      ),
    );
  }
}

/// Personality picker styled like [AppTextField].
class _PersonalityField extends StatelessWidget {
  const _PersonalityField({required this.controller});

  final CustomizeAiController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: controller.personality.value,
      onChanged: controller.onPersonalityChanged,
      isExpanded: true,
      dropdownColor: context.color.inputFill,
      borderRadius: BorderRadius.circular(14),
      style: AppTextField.textStyle(context),
      icon: Icon(
        PhosphorIconsRegular.caretDown,
        size: 20,
        color: context.color.textNatural,
      ),
      decoration: AppTextField.decoration(
        context,
        prefixIcon: PhosphorIconsRegular.user,
      ),
      items: [
        for (final key in CustomizeAiController.personalityKeys)
          DropdownMenuItem(
            value: key,
            child: CustomText(
              key.tr,
              maxLines: 1,
              fontSize: 16,
              color: context.color.textNatural,
            ),
          ),
      ],
    );
  }
}
