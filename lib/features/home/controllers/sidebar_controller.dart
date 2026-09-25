import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/routes/app_routes.dart';

/// A row in one of the sidebar menu cards.
class SidebarItem {
  const SidebarItem({
    required this.labelKey,
    required this.icon,
    this.iconColor,
    this.showArrow = false,
  });

  /// Translation key of the label.
  final String labelKey;
  final IconData icon;

  /// Tint of the icon; defaults to the regular text colour.
  final Color? iconColor;
  final bool showArrow;
}

/// A past conversation listed under "Chats".
class ChatSummary {
  const ChatSummary({required this.id, required this.title});

  final String id;
  final String title;
}

/// State shared by the home drawer and the search screen.
class SidebarController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  static const actions = [
    SidebarItem(
      labelKey: 'sidebar_new_chat',
      icon: PhosphorIconsRegular.plusCircle,
      showArrow: true,
    ),
    SidebarItem(
      labelKey: 'sidebar_temporary_chat',
      icon: PhosphorIconsRegular.chatCircle,
      showArrow: true,
    ),
    SidebarItem(
      labelKey: 'sidebar_presets',
      icon: PhosphorIconsRegular.lightning,
      showArrow: true,
    ),
  ];

  static const projects = [
    SidebarItem(
      labelKey: 'sidebar_new_project',
      icon: PhosphorIconsRegular.folderPlus,
    ),
    SidebarItem(
      labelKey: 'sidebar_research',
      icon: PhosphorIconsRegular.lightbulb,
      iconColor: Color(0xFFFACC15),
    ),
    SidebarItem(
      labelKey: 'sidebar_education',
      icon: PhosphorIconsRegular.bookOpen,
      iconColor: Color(0xFFF43F5E),
    ),
    SidebarItem(
      labelKey: 'sidebar_view_ai',
      icon: PhosphorIconsRegular.dotsThree,
      showArrow: true,
    ),
  ];

  // TODO: load the user's chats and profile once the API exists.
  final chats = <ChatSummary>[
    const ChatSummary(id: '1', title: 'Multiverse & Cosmic Power'),
    const ChatSummary(id: '2', title: 'Incursion of tow universes'),
    const ChatSummary(id: '3', title: 'Astral travel & Subconscious'),
  ].obs;
  final selectedChatId = RxnString('1');

  final userName = 'Mikel Strome';
  final userEmail = 'designer@gmail.com';

  /// Chats whose title contains the search query.
  List<ChatSummary> get filteredChats {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
  }

  void onSearch() => Get.toNamed(AppRoutes.search);

  /// Leaves the search screen, clearing the query for next time.
  void onSearchBack() {
    searchController.clear();
    Get.back();
  }

  /// Selects [chat]; the home screen closes the drawer to show it.
  void onChat(ChatSummary chat) {
    selectedChatId.value = chat.id;
    if (Get.currentRoute == AppRoutes.search) onSearchBack();
  }

  void onProfile() => Get.toNamed(AppRoutes.profile);

  // TODO: wire these up once chats and projects exist.
  void onItem(SidebarItem item) {}
  void onChatMore(ChatSummary chat) {}

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
