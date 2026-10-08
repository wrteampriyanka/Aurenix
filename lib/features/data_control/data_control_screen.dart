import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_settings_tile.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/data_control/controllers/data_control_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class DataControlScreen extends GetView<DataControlController> {
  const DataControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.dataControlTitle.tr,
      bottom: AppButton(
        label: AppStrings.dataControlDeleteAccount.tr,
        icon: null,
        height: 52,
        fontSize: AppFontSize.body,
        color: appColors.upgradeButton,
        highlightColor: appColors.upgradeButtonHighlight,
        borderColor: appColors.upgradeButtonBorder,
        onPressed: controller.onDeleteAccount,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppToggleCard(
              title: AppStrings.dataControlImproveTitle.tr,
              subtitle: AppStrings.dataControlImproveSubtitle.tr,
              value: controller.improveModel.value,
              onChanged: controller.onImproveModel,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSettingsTile(
            icon: PhosphorIconsRegular.fileText,
            title: AppStrings.dataControlExportTitle.tr,
            subtitle: AppStrings.dataControlExportSubtitle.tr,
            onTap: controller.onExportData,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: AppStrings.dataControlDeleteConversations.tr,
            onTap: controller.onDeleteConversationData,
          ),
          _SectionLabel(AppStrings.dataControlVoiceSection.tr),
          Obx(
            () => AppToggleCard(
              title: AppStrings.dataControlVoiceTitle.tr,
              subtitle: AppStrings.dataControlVoiceSubtitle.tr,
              value: controller.includeVoiceData.value,
              onChanged: controller.onIncludeVoiceData,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: AppStrings.dataControlDeleteVoice.tr,
            onTap: controller.onDeleteVoiceData,
          ),
          _SectionLabel(AppStrings.dataControlHistorySection.tr),
          AppSettingsTile(
            icon: PhosphorIconsRegular.arrowCircleDown,
            title: AppStrings.dataControlArchiveAll.tr,
            onTap: controller.onArchiveAllChats,
          ),
          const SizedBox(height: AppSpacing.md),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: AppStrings.dataControlDeleteAllChats.tr,
            onTap: controller.onDeleteAllChats,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: AppText(
        text,
        maxLines: 1,
        fontSize: AppFontSize.overline,
        color: appColors.textBody,
      ),
    );
  }
}
