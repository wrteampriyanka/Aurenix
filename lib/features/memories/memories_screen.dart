import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_search_field.dart';
import 'package:aurenix/commons/widgets/app_settings_tile.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/memories/controllers/memories_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class MemoriesScreen extends GetView<MemoriesController> {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.memoriesTitle.tr,
      bottom: Obx(
        () => AppButton(
          label: AppStrings.memoriesRemoveAll.tr,
          icon: null,
          height: 52,
          fontSize: AppFontSize.body,
          color: appColors.upgradeButton,
          highlightColor: appColors.upgradeButtonHighlight,
          borderColor: appColors.upgradeButtonBorder,
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
              title: AppStrings.memoriesSavedTitle.tr,
              subtitle: AppStrings.memoriesSavedSubtitle.tr,
              value: controller.referenceSavedMemories.value,
              onChanged: controller.onReferenceSavedMemories,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => AppToggleCard(
              title: AppStrings.memoriesHistoryTitle.tr,
              subtitle: AppStrings.memoriesHistorySubtitle.tr,
              value: controller.referenceChatHistory.value,
              onChanged: controller.onReferenceChatHistory,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppSearchField(
            controller: controller.searchController,
            hintText: AppStrings.memoriesSearchHint.tr,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            AppStrings.memoriesAll.tr,
            maxLines: 1,
            fontSize: AppFontSize.overline,
            color: appColors.textBody,
          ),
          const SizedBox(height: AppSpacing.md),
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
            child: AppText(
              controller.memories.isEmpty
                  ? AppStrings.memoriesEmpty.tr
                  : AppStrings.memoriesNoResults.tr,
              fontSize: AppFontSize.label,
              textAlign: TextAlign.center,
              color: appColors.textBody,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, memory) in memories.indexed) ...[
              if (i > 0) const SizedBox(height: AppSpacing.lg),
              AppText(
                memory,
                fontSize: AppFontSize.chat,
                color: appColors.textNatural,
              ),
            ],
          ],
        );
      }),
    );
  }
}
