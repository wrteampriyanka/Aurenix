import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_button.dart';
import '../widgets/app_plain_background.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_settings_tile.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/memories/controllers/memories_controller.dart';

class MemoriesScreen extends GetView<MemoriesController> {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'memories_title'.tr,
      bottom: Obx(
        () => AppButton(
          label: 'memories_remove_all'.tr,
          icon: null,
          height: 52,
          fontSize: 16,
          color: context.color.upgradeButton,
          highlightColor: context.color.upgradeButtonHighlight,
          borderColor: context.color.upgradeButtonBorder,
          onPressed: controller.memories.isEmpty
              ? null
              : controller.onRemoveAll,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppToggleCard(
              title: 'memories_saved_title'.tr,
              subtitle: 'memories_saved_subtitle'.tr,
              value: controller.referenceSavedMemories.value,
              onChanged: controller.onReferenceSavedMemories,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => AppToggleCard(
              title: 'memories_history_title'.tr,
              subtitle: 'memories_history_subtitle'.tr,
              value: controller.referenceChatHistory.value,
              onChanged: controller.onReferenceChatHistory,
            ),
          ),
          const SizedBox(height: 20),
          AppSearchField(
            controller: controller.searchController,
            hintText: 'memories_search_hint'.tr,
          ),
          const SizedBox(height: 20),
          CustomText(
            'memories_all'.tr,
            maxLines: 1,
            fontSize: 12,
            color: context.color.textBody,
          ),
          const SizedBox(height: 12),
          _MemoriesList(controller: controller),
        ],
      ),
    );
  }
}

class _MemoriesList extends StatelessWidget {
  const _MemoriesList({required this.controller});

  final MemoriesController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Obx(() {
        final memories = controller.filteredMemories;
        if (memories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CustomText(
              controller.memories.isEmpty
                  ? 'memories_empty'.tr
                  : 'memories_no_results'.tr,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: context.color.textBody,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, memory) in memories.indexed) ...[
              if (i > 0) const SizedBox(height: 16),
              CustomText(
                memory,
                fontSize: 15,
                color: context.color.textNatural,
              ),
            ],
          ],
        );
      }),
    );
  }
}
