import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_plain_background.dart';
import '../../../commons/widgets/app_text_field.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../utils/validators.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'edit_profile_title'.tr,
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
            label: 'edit_profile_save'.tr,
            icon: null,
            height: 52,
            fontSize: 16,
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
              hint: 'name_hint'.tr,
              prefixIcon: PhosphorIconsRegular.userCircle,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: controller.validateName,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _GenderField(controller: controller)),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: controller.ageController,
                    hint: 'edit_profile_age_hint'.tr,
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
        hint: 'edit_profile_gender_hint'.tr,
      ),
      items: [
        for (final key in EditProfileController.genderKeys)
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

/// Dismissible note about how the user's data is stored.
class _DataNotice extends StatelessWidget {
  const _DataNotice({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: context.color.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              'edit_profile_data_notice'.tr,
              fontSize: 13,
              color: context.color.textBody,
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              PhosphorIconsRegular.x,
              size: 20,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
