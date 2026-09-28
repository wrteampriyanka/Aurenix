import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_plain_background.dart';
import '../../../commons/widgets/app_settings_tile.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/memories_controller.dart';

class MemoriesView extends GetView<MemoriesController> {
  const MemoriesView({super.key});

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
          onPressed: controller.memories.isEmpty ? null : controller.onRemoveAll,
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
          _SearchField(controller: controller),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final MemoriesController controller;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: color.inputFill,
        borderRadius: BorderRadius.circular(_height / 2),
        border: Border.all(color: color.inputBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 22,
            color: color.textNatural,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              cursorColor: color.primary,
              style: TextStyle(color: color.textNatural, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'memories_search_hint'.tr,
                hintStyle: TextStyle(color: color.textBody, fontSize: 15),
                hintMaxLines: 1,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Obx(
            () => controller.query.value.isEmpty
                ? const SizedBox(width: 14)
                : InkResponse(
                    onTap: controller.searchController.clear,
                    radius: 18,
                    child: SizedBox(
                      width: 40,
                      height: _height,
                      child: Icon(
                        PhosphorIconsFill.xCircle,
                        size: 18,
                        color: color.textBody,
                      ),
                    ),
                  ),
          ),
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
