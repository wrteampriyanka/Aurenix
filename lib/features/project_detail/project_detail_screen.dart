import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/features/widgets/app_detail_app_bar.dart';
import 'package:aurenix/features/widgets/app_search_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/features/project_detail/controllers/project_detail_controller.dart';

/// A single project: its chats, with a composer for starting a new one.
class ProjectDetailScreen extends GetView<ProjectDetailController> {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundBase,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDetailAppBar(
              title: '',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconButton(
                    icon: PhosphorIconsRegular.fileText,
                    onTap: controller.onFiles,
                  ),
                  const SizedBox(width: 8),
                  _IconButton(
                    icon: PhosphorIconsRegular.dotsThree,
                    onTap: controller.onMenu,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                      child: Obx(() {
                        final project = controller.project;
                        if (project == null) return const SizedBox.shrink();
                        return _Header(
                          project: project,
                          onShare: controller.onShare,
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: AppSearchField(
                        controller: controller.searchController,
                        hintText: 'project_detail_search_hint'.tr,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _ChatsCard(controller: controller),
                      ),
                    ),
                    _Composer(controller: controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Project icon, name and chat count, with the share pill at the end.
class _Header extends StatelessWidget {
  const _Header({required this.project, required this.onShare});

  final Project project;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: project.iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.tileBorder),
          ),
          child: Icon(project.icon, size: 22, color: project.iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                project.name,
                maxLines: 1,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color.textNatural,
              ),
              const SizedBox(height: 2),
              CustomText(
                'projects_chats'.trParams({'count': '${project.chatCount}'}),
                fontSize: 12,
                color: color.textBody,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: color.inputFill,
          shape: StadiumBorder(side: BorderSide(color: color.tileBorder)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onShare,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.shareNetwork,
                    size: 16,
                    color: color.textNatural,
                  ),
                  const SizedBox(width: 8),
                  CustomText(
                    'project_detail_share'.tr,
                    fontSize: 13,
                    color: color.textNatural,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The project's chats in one outlined card, divided row by row.
class _ChatsCard extends StatelessWidget {
  const _ChatsCard({required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
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
                    ? 'project_detail_empty'.tr
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
                  onMore: () => controller.onChatMore(chat),
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
    required this.onMore,
  });

  final ChatSummary chat;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  chat.title,
                  maxLines: 1,
                  fontSize: 15,
                  color: color.textNatural,
                ),
              ),
              if (chat.authorInitials case final initials?) ...[
                const SizedBox(width: 10),
                _Avatar(
                  initials: initials,
                  color: chat.authorColor ?? color.primary,
                ),
              ],
              InkResponse(
                onTap: onMore,
                radius: 18,
                child: SizedBox(
                  width: 32,
                  height: 52,
                  child: Icon(
                    PhosphorIconsRegular.dotsThree,
                    size: 16,
                    color: color.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small circle with the initials of whoever started the chat.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: CustomText(
        initials,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: context.color.textNatural,
      ),
    );
  }
}

/// Pinned at the bottom: start a chat in this project without going back.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller});

  final ProjectDetailController controller;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: color.inputFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.inputBorder),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    PhosphorIconsRegular.plus,
                    size: 20,
                    color: color.textNatural,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      cursorColor: color.primary,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.onSend(),
                      style: TextStyle(color: color.textNatural, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'home_input_hint'.tr,
                        hintStyle: TextStyle(
                          color: color.textBody,
                          fontSize: 15,
                        ),
                        hintMaxLines: 1,
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    PhosphorIconsRegular.microphone,
                    size: 20,
                    color: color.textNatural,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => Material(
              color: color.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: controller.hasText.value
                    ? controller.onSend
                    : controller.onVoice,
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(
                    controller.hasText.value
                        ? PhosphorIconsRegular.arrowUp
                        : PhosphorIconsRegular.waveform,
                    size: 22,
                    color: color.textOnPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round icon button used in the app bar.
class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.inputFill,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, size: 20, color: context.color.textNatural),
        ),
      ),
    );
  }
}
