import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_settings_tile.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/customize_ai/controllers/customize_ai_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class CustomizeAiScreen extends GetView<CustomizeAiController> {
  const CustomizeAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.customizeAiTitle.tr,
      bottom: AppButton(
        label: AppStrings.customizeAiSave.tr,
        icon: null,
        height: 52,
        fontSize: AppFontSize.body,
        onPressed: controller.onSave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppToggleCard(
              title: AppStrings.customizeAiToggleTitle.tr,
              subtitle: AppStrings.customizeAiToggleSubtitle.tr,
              value: controller.isEnabled.value,
              onChanged: controller.onToggle,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xl),
          AppSettingsTile(
            icon: PhosphorIconsRegular.notebook,
            title: AppStrings.customizeAiMemories.tr,
            subtitle: AppStrings.customizeAiMemoriesSubtitle.tr,
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
        _SectionLabel(AppStrings.customizeAiPersonality.tr),
        _PersonalityField(controller: controller),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.instructionsController,
          label: AppStrings.customizeAiInstructionsLabel.tr,
          hint: AppStrings.customizeAiInstructionsHint.tr,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SectionLabel(AppStrings.customizeAiYourInfo.tr),
        AppTextField(
          controller: controller.nicknameController,
          label: AppStrings.customizeAiNicknameLabel.tr,
          prefixIcon: PhosphorIconsRegular.userCircle,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.nickname],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.occupationController,
          label: AppStrings.customizeAiOccupationLabel.tr,
          prefixIcon: PhosphorIconsRegular.briefcase,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.jobTitle],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.aboutController,
          label: AppStrings.customizeAiAboutLabel.tr,
          hint: AppStrings.customizeAiAboutHint.tr,
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
      child: AppText(
        text,
        maxLines: 1,
        fontSize: AppFontSize.caption,
        color: appColors.textBody,
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
      dropdownColor: appColors.inputFill,
      borderRadius: BorderRadius.circular(14),
      style: AppTextField.textStyle(context),
      icon: Icon(
        PhosphorIconsRegular.caretDown,
        size: 20,
        color: appColors.textNatural,
      ),
      decoration: AppTextField.decoration(
        context,
        prefixIcon: PhosphorIconsRegular.user,
      ),
      items: [
        for (final key in CustomizeAiController.personalityKeys)
          DropdownMenuItem(
            value: key,
            child: AppText(
              key.tr,
              maxLines: 1,
              fontSize: AppFontSize.body,
              color: appColors.textNatural,
            ),
          ),
      ],
    );
  }
}
