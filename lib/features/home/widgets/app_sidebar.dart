import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/sidebar_controller.dart';

/// Menu, chats and profile shown in the home drawer and on the search screen.
///
/// In the drawer the search field is a button that opens the search screen;
/// on the search screen ([isSearch]) it is a live field that filters the
/// chats, with a back button in front of it.
class AppSidebar extends GetView<SidebarController> {
  const AppSidebar({super.key, this.isSearch = false});

  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                if (isSearch) ...[
                  _RoundButton(
                    icon: PhosphorIconsRegular.caretLeft,
                    onTap: controller.onSearchBack,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(child: _SearchField(isSearch: isSearch)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                _MenuCard(items: SidebarController.actions),
                const SizedBox(height: 12),
                _MenuCard(items: SidebarController.projects),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 8),
                  child: CustomText(
                    'sidebar_chats'.tr,
                    fontSize: 12,
                    color: context.color.textBody,
                  ),
                ),
                const _ChatsCard(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _ProfileTile(controller: controller),
          ),
        ],
      ),
    );
  }
}

/// Rounded outlined box shared by the sidebar cards.
BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: context.color.sidebarCard,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: context.color.tileBorder),
);

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.tileFill,
      shape: CircleBorder(side: BorderSide(color: context.color.tileBorder)),
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

class _SearchField extends GetView<SidebarController> {
  const _SearchField({required this.isSearch});

  final bool isSearch;

  static const double _radius = 22;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_radius),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        // The drawer only shows the field; typing happens on the search screen.
        controller: isSearch ? controller.searchController : null,
        readOnly: !isSearch,
        autofocus: isSearch,
        onTap: isSearch ? null : controller.onSearch,
        textInputAction: TextInputAction.search,
        cursorColor: context.color.primary,
        style: TextStyle(color: context.color.textNatural, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'sidebar_search_hint'.tr,
          hintStyle: TextStyle(color: context.color.textBody, fontSize: 14),
          filled: true,
          fillColor: context.color.tileFill,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 20,
              color: context.color.textNatural,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          border: _border(context.color.tileBorder),
          enabledBorder: _border(context.color.tileBorder),
          focusedBorder: _border(
            isSearch ? context.color.primary : context.color.tileBorder,
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends GetView<SidebarController> {
  const _MenuCard({required this.items});

  final List<SidebarItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                  color: context.color.tileBorder,
                ),
              _MenuRow(
                item: items[i],
                onTap: () => controller.onItem(items[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final SidebarItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: item.iconColor ?? context.color.textNatural,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                item.labelKey.tr,
                maxLines: 1,
                fontSize: 14,
                color: context.color.textNatural,
              ),
            ),
            if (item.showArrow)
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: context.color.textNatural,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatsCard extends GetView<SidebarController> {
  const _ChatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _cardDecoration(context),
      child: Obx(() {
        final chats = controller.filteredChats;
        if (chats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: CustomText(
              'sidebar_no_chats'.tr,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: context.color.textBody,
            ),
          );
        }
        final selectedId = controller.selectedChatId.value;
        return Column(
          children: [
            for (final chat in chats)
              _ChatRow(
                chat: chat,
                selected: chat.id == selectedId,
                onTap: () => controller.onChat(chat),
                onMore: () => controller.onChatMore(chat),
              ),
          ],
        );
      }),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.chat,
    required this.selected,
    required this.onTap,
    required this.onMore,
  });

  final ChatSummary chat;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.color.sidebarSelected : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  chat.title,
                  maxLines: 1,
                  fontSize: 14,
                  color: context.color.textNatural,
                ),
              ),
              InkResponse(
                onTap: onMore,
                radius: 18,
                child: SizedBox(
                  width: 36,
                  height: 38,
                  child: Icon(
                    PhosphorIconsRegular.dotsThreeVertical,
                    size: 16,
                    color: context.color.textBody,
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

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.controller});

  final SidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: controller.onProfile,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.primary,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.user,
                    size: 20,
                    color: context.color.textNatural,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        controller.userName,
                        maxLines: 1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.color.textNatural,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        controller.userEmail,
                        maxLines: 1,
                        fontSize: 12,
                        color: context.color.textBody,
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: context.color.textNatural,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
