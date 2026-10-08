import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/validators.dart';
import 'package:aurenix/features/edit_profile/controllers/edit_profile_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.editProfileTitle.tr,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => controller.isNoticeVisible.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DataNotice(onClose: controller.dismissNotice),
                  )
                : const SizedBox.shrink(),
          ),
          AppButton(
            label: AppStrings.editProfileSave.tr,
            icon: null,
            height: 52,
            fontSize: AppFontSize.body,
            onPressed: controller.onSave,
          ),
        ],
      ),
      child: _EditForm(controller: controller),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({required this.controller});

  final EditProfileController controller;

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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: controller.validateName,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _GenderField(controller: controller)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(
                    controller: controller.ageController,
                    label: AppStrings.fieldAgeLabel.tr,
                    // Shares a Row with the gender picker.
                    reserveErrorSpace: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: controller.validateAge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gender picker styled like [AppTextField].
class _GenderField extends StatelessWidget {
  const _GenderField({required this.controller});

  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: controller.gender.value,
      onChanged: controller.onGenderChanged,
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
        hint: AppStrings.editProfileGenderHint.tr,
      ),
      items: [
        for (final key in EditProfileController.genderKeys)
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

/// Dismissible note about how the user's data is stored.
class _DataNotice extends StatelessWidget {
  const _DataNotice({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: appColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              AppStrings.editProfileDataNotice.tr,
              fontSize: AppFontSize.caption,
              color: appColors.textBody,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              PhosphorIconsRegular.x,
              size: 20,
              color: appColors.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
