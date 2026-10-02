import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../widgets/custom_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/home/controllers/sidebar_controller.dart';

/// Menu, chats and profile shown in the home drawer.
///
/// Tapping the search pill turns the drawer into a full-screen search in
/// place: the pill lights up and becomes a live field, and a back button
/// slides in front of it. See [SidebarController.search].
class AppSidebar extends GetView<SidebarController> {
  const AppSidebar({super.key});

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
                _BackButton(controller: controller),
                const Expanded(child: _SearchField()),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              children: [
                _MenuCard(
                  children: [
                    for (final item in SidebarController.actions)
                      _itemRow(item),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _MenuCard(
                    children: [
                      _itemRow(SidebarController.newProjectItem),
                      for (final project in controller.projects.take(
                        SidebarController.sidebarProjectCount,
                      ))
                        _MenuRow(
                          label: project.name,
                          icon: project.icon,
                          iconColor: project.iconColor,
                          onTap: () => controller.onProject(project),
                        ),
                      _itemRow(SidebarController.viewAllItem),
                    ],
                  ),
                ),
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

  _MenuRow _itemRow(SidebarItem item) => _MenuRow(
    label: item.labelKey.tr,
    icon: item.icon,
    iconColor: item.iconColor,
    showArrow: item.showArrow,
    onTap: () => controller.onItem(item),
  );
}

/// Rounded outlined box shared by the sidebar cards.
BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: context.color.sidebarCard,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: context.color.tileBorder),
);

/// Back button that grows in front of the search field while searching.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.controller});

  final SidebarController controller;

  static const _interval = Interval(0.35, 1, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.search,
      builder: (context, child) {
        final t = _interval.transform(controller.search.value);
        if (t == 0) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: t,
            child: Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.5 + 0.5 * t, child: child),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: _RoundButton(
          icon: PhosphorIconsRegular.caretLeft,
          onTap: controller.onSearchBack,
        ),
      ),
    );
  }
}

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

/// Search pill: a button in the drawer, a live field while searching.
///
/// Its border and glow light up with [SidebarController.search], and the
/// magnifying glass gives a small tilt on the way.
class _SearchField extends GetView<SidebarController> {
  const _SearchField();

  static const double _height = 44;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return AnimatedBuilder(
      animation: controller.search,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.search.value);
        final wiggle = math.sin(t * math.pi);
        return Container(
          height: _height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color.tileFill,
            borderRadius: BorderRadius.circular(_height / 2),
            border: Border.all(
              color: Color.lerp(color.tileBorder, color.primary, t)!,
            ),
            boxShadow: [
              BoxShadow(
                color: color.primary.withValues(alpha: 0.28 * t),
                blurRadius: 18 * t,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Obx(() {
              final searching = controller.isSearching.value;
              return InkWell(
                onTap: searching ? null : controller.onSearch,
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Transform.rotate(
                      angle: wiggle * -0.35,
                      child: Transform.scale(
                        scale: 1 + wiggle * 0.25,
                        child: Icon(
                          PhosphorIconsRegular.magnifyingGlass,
                          size: 20,
                          color: Color.lerp(
                            color.textNatural,
                            color.primary,
                            t,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // The hint and the field look the same, so swapping
                    // them is invisible.
                    Expanded(
                      child: searching
                          ? TextField(
                              controller: controller.searchController,
                              focusNode: controller.searchFocus,
                              textInputAction: TextInputAction.search,
                              cursorColor: color.primary,
                              style: TextStyle(
                                color: color.textNatural,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'sidebar_search_hint'.tr,
                                hintStyle: TextStyle(
                                  color: color.textBody,
                                  fontSize: 14,
                                ),
                                hintMaxLines: 1,
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                            )
                          : CustomText(
                              'sidebar_search_hint'.tr,
                              maxLines: 1,
                              fontSize: 14,
                              color: color.textBody,
                            ),
                    ),
                    _ClearButton(controller: controller),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Pops in at the end of the search field once something is typed.
class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final SidebarController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: controller.query.value.isEmpty
            ? const SizedBox(key: ValueKey('empty'), width: 14)
            : InkResponse(
                key: const ValueKey('clear'),
                onTap: controller.searchController.clear,
                radius: 18,
                child: SizedBox(
                  width: 40,
                  height: _SearchField._height,
                  child: Icon(
                    PhosphorIconsFill.xCircle,
                    size: 18,
                    color: context.color.textBody,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<_MenuRow> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                  color: context.color.tileBorder,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.showArrow = false,
  });

  final String label;
  final IconData icon;

  /// Defaults to the regular text colour.
  final Color? iconColor;
  final bool showArrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? context.color.textNatural),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                label,
                maxLines: 1,
                fontSize: 14,
                color: context.color.textNatural,
              ),
            ),
            if (showArrow)
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
      // Results resize and cross-fade as the query changes.
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Obx(() {
          final chats = controller.filteredChats;
          final selectedId = controller.selectedChatId.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: chats.isEmpty
                ? Padding(
                    key: const ValueKey('empty'),
                    padding: const EdgeInsets.all(12),
                    child: CustomText(
                      'sidebar_no_chats'.tr,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                      color: context.color.textBody,
                    ),
                  )
                : Column(
                    key: ValueKey(chats.map((c) => c.id).join(',')),
                    children: [
                      for (final chat in chats)
                        _ChatRow(
                          chat: chat,
                          selected: chat.id == selectedId,
                          onTap: () => controller.onChat(chat),
                          onMore: () => controller.onChatMore(chat),
                        ),
                    ],
                  ),
          );
        }),
      ),
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
