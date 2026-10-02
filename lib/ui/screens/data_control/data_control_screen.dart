import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/app_button.dart';
import '../widgets/app_plain_background.dart';
import '../widgets/app_settings_tile.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/data_control/controllers/data_control_controller.dart';

class DataControlScreen extends GetView<DataControlController> {
  const DataControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'data_control_title'.tr,
      bottom: AppButton(
        label: 'data_control_delete_account'.tr,
        icon: null,
        height: 52,
        fontSize: 16,
        color: context.color.upgradeButton,
        highlightColor: context.color.upgradeButtonHighlight,
        borderColor: context.color.upgradeButtonBorder,
        onPressed: controller.onDeleteAccount,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppToggleCard(
              title: 'data_control_improve_title'.tr,
              subtitle: 'data_control_improve_subtitle'.tr,
              value: controller.improveModel.value,
              onChanged: controller.onImproveModel,
            ),
          ),
          const SizedBox(height: 12),
          AppSettingsTile(
            icon: PhosphorIconsRegular.fileText,
            title: 'data_control_export_title'.tr,
            subtitle: 'data_control_export_subtitle'.tr,
            onTap: controller.onExportData,
          ),
          const SizedBox(height: 12),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: 'data_control_delete_conversations'.tr,
            onTap: controller.onDeleteConversationData,
          ),
          _SectionLabel('data_control_voice_section'.tr),
          Obx(
            () => AppToggleCard(
              title: 'data_control_voice_title'.tr,
              subtitle: 'data_control_voice_subtitle'.tr,
              value: controller.includeVoiceData.value,
              onChanged: controller.onIncludeVoiceData,
            ),
          ),
          const SizedBox(height: 12),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: 'data_control_delete_voice'.tr,
            onTap: controller.onDeleteVoiceData,
          ),
          _SectionLabel('data_control_history_section'.tr),
          AppSettingsTile(
            icon: PhosphorIconsRegular.arrowCircleDown,
            title: 'data_control_archive_all'.tr,
            onTap: controller.onArchiveAllChats,
          ),
          const SizedBox(height: 12),
          AppSettingsTile(
            icon: PhosphorIconsRegular.trash,
            title: 'data_control_delete_all_chats'.tr,
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
      child: CustomText(
        text,
        maxLines: 1,
        fontSize: 12,
        color: context.color.textBody,
      ),
    );
  }
}
