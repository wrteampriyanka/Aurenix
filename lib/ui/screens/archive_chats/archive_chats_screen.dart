import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/app_plain_background.dart';
import '../widgets/app_search_field.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../home/controllers/sidebar_controller.dart';
import 'controllers/archive_chats_controller.dart';

class ArchiveChatsScreen extends GetView<ArchiveChatsController> {
  const ArchiveChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'archive_chats_title'.tr,
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: AppSearchField(
          controller: controller.searchController,
          hintText: 'archive_chats_search_hint'.tr,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _ChatsCard(controller: controller),
    );
  }
}

class _ChatsCard extends StatelessWidget {
  const _ChatsCard({required this.controller});

  final ArchiveChatsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.color.tileBorder),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Obx(() {
          final chats = controller.filteredChats;
          if (chats.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CustomText(
                controller.chats.isEmpty
                    ? 'archive_chats_empty'.tr
                    : 'sidebar_no_chats'.tr,
                fontSize: 14,
                textAlign: TextAlign.center,
                color: context.color.textBody,
              ),
            );
          }
          return Column(
            children: [
              for (final (i, chat) in chats.indexed) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.color.divider,
                  ),
                _ChatRow(
                  chat: chat,
                  onTap: () => controller.onChat(chat),
                  onAction: (action) => controller.onAction(chat, action),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.chat,
    required this.onTap,
    required this.onAction,
  });

  final ChatSummary chat;
  final VoidCallback onTap;
  final ValueChanged<ArchivedChatAction> onAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  chat.title,
                  maxLines: 1,
                  fontSize: 15,
                  color: context.color.textNatural,
                ),
              ),
              _MoreMenu(onSelected: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "..." button with the unarchive and delete options.
class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.onSelected});

  final ValueChanged<ArchivedChatAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return PopupMenuButton<ArchivedChatAction>(
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      color: color.sheetCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.tileBorder),
      ),
      itemBuilder: (context) => [
        _item(
          context,
          ArchivedChatAction.unarchive,
          'archive_chats_unarchive'.tr,
          PhosphorIconsRegular.arrowCircleUp,
          color.textNatural,
        ),
        _item(
          context,
          ArchivedChatAction.delete,
          'archive_chats_delete'.tr,
          PhosphorIconsRegular.trash,
          color.error,
        ),
      ],
      child: SizedBox(
        width: 32,
        height: 50,
        child: Icon(
          PhosphorIconsRegular.dotsThree,
          size: 16,
          color: color.textBody,
        ),
      ),
    );
  }

  PopupMenuItem<ArchivedChatAction> _item(
    BuildContext context,
    ArchivedChatAction value,
    String label,
    IconData icon,
    Color tint,
  ) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 20, color: tint),
          const SizedBox(width: 12),
          CustomText(label, fontSize: 14, color: tint),
        ],
      ),
    );
  }
}
