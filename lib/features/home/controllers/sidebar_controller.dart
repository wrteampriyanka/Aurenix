import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_picker_sheet.dart';
import '../../../core/routes/app_routes.dart';
import '../../projects/widgets/create_project_sheet.dart';
import 'home_controller.dart';

/// What a sidebar menu row does when tapped.
enum SidebarAction { newChat, temporaryChat, presets, newProject, viewAll }

/// A row in one of the sidebar menu cards.
class SidebarItem {
  const SidebarItem({
    required this.action,
    required this.labelKey,
    required this.icon,
    this.iconColor,
    this.showArrow = false,
  });

  final SidebarAction action;

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

/// A folder of chats, listed in the sidebar and on the projects screen.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    this.chatCount = 0,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;
  final int chatCount;
}

/// State of the home drawer, including its in-place search.
class SidebarController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  final query = ''.obs;

  /// Search mode: 0 regular drawer, 1 full-screen search.
  late final search = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  final isSearching = false.obs;

  static const actions = [
    SidebarItem(
      action: SidebarAction.newChat,
      labelKey: 'sidebar_new_chat',
      icon: PhosphorIconsRegular.plusCircle,
      showArrow: true,
    ),
    SidebarItem(
      action: SidebarAction.temporaryChat,
      labelKey: 'sidebar_temporary_chat',
      icon: PhosphorIconsRegular.chatCircle,
      showArrow: true,
    ),
    SidebarItem(
      action: SidebarAction.presets,
      labelKey: 'sidebar_presets',
      icon: PhosphorIconsRegular.lightning,
      showArrow: true,
    ),
  ];

  static const newProjectItem = SidebarItem(
    action: SidebarAction.newProject,
    labelKey: 'sidebar_new_project',
    icon: PhosphorIconsRegular.folderPlus,
  );

  static const viewAllItem = SidebarItem(
    action: SidebarAction.viewAll,
    labelKey: 'sidebar_view_all',
    icon: PhosphorIconsRegular.dotsThree,
    showArrow: true,
  );

  /// How many projects the sidebar lists before "View All".
  static const sidebarProjectCount = 2;

  /// Tints given to new projects in turn.
  static const _projectColors = [
    Color(0xFF38BDF8),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFF59E0B),
  ];

  // TODO: load the user's projects once the API exists.
  final projects = <Project>[
    Project(
      id: 'p1',
      name: 'sidebar_research'.tr,
      icon: PhosphorIconsRegular.lightbulb,
      iconColor: const Color(0xFFFACC15),
      chatCount: 32,
    ),
    Project(
      id: 'p2',
      name: 'sidebar_education'.tr,
      icon: PhosphorIconsRegular.bookOpen,
      iconColor: const Color(0xFFF43F5E),
      chatCount: 16,
    ),
    const Project(
      id: 'p3',
      name: 'Business',
      icon: PhosphorIconsRegular.monitor,
      iconColor: Color(0xFF3B82F6),
      chatCount: 43,
    ),
    const Project(
      id: 'p4',
      name: 'My Ideas',
      icon: PhosphorIconsRegular.lightning,
      iconColor: Color(0xFFF59E0B),
      chatCount: 23,
    ),
  ].obs;

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

  /// Expands the drawer into search, opening the keyboard once it settles
  /// so it does not fight the animation.
  void onSearch() {
    isSearching.value = true;
    search.forward().then((_) {
      if (isSearching.value) searchFocus.requestFocus();
    });
  }

  /// Shrinks search back to the drawer, clearing the query for next time.
  void onSearchBack() {
    searchFocus.unfocus();
    searchController.clear();
    isSearching.value = false;
    search.reverse();
  }

  /// Selects [chat]; the home screen closes the drawer to show it.
  void onChat(ChatSummary chat) {
    selectedChatId.value = chat.id;
    if (isSearching.value) onSearchBack();
  }

  void onProfile() => Get.toNamed(AppRoutes.profile);

  HomeController get _home => Get.find<HomeController>();

  void onItem(SidebarItem item) {
    switch (item.action) {
      case SidebarAction.newChat:
        _startChat();
      case SidebarAction.temporaryChat:
        _startChat(temporary: true);
        Get.rawSnackbar(
          message: 'sidebar_temporary_chat_on'.tr,
          duration: const Duration(seconds: 2),
        );
      case SidebarAction.presets:
        _pickPreset();
      case SidebarAction.newProject:
        onCreateProject();
      case SidebarAction.viewAll:
        Get.toNamed(AppRoutes.projects);
    }
  }

  /// Clears the conversation and shows it, deselecting any past chat.
  void _startChat({bool temporary = false}) {
    selectedChatId.value = null;
    _home.onNewChat(temporary: temporary);
    _home.closeDrawer();
  }

  /// Lets the user pick one of the home actions (Code, Research, ...) to
  /// tag the next message with.
  Future<void> _pickPreset() async {
    final action = await AppPickerSheet.show<HomeAction>(
      title: 'sidebar_presets'.tr,
      items: HomeController.actions,
      labelOf: (a) => a.labelKey.tr,
      selected: _home.selectedAction.value,
      leadingOf: (a) => SvgPicture.asset(a.icon, width: 20, height: 20),
    );
    if (action == null) return;
    _home.onAction(action);
    _home.closeDrawer();
  }

  /// Asks for a name and adds the project to the top of the list.
  Future<void> onCreateProject() async {
    final name = await CreateProjectSheet.show();
    if (name == null) return;
    projects.insert(
      0,
      Project(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        icon: PhosphorIconsRegular.folder,
        iconColor: _projectColors[projects.length % _projectColors.length],
      ),
    );
  }

  // TODO: open the project's chats once chats can be stored by project.
  /// Starts a new chat for [project] back on the home screen.
  void onProject(Project project) {
    Get.until((route) => route.settings.name == AppRoutes.home);
    _startChat();
    Get.rawSnackbar(
      message: 'projects_new_chat_in'.trParams({'name': project.name}),
      duration: const Duration(seconds: 2),
    );
  }

  // TODO: wire this up once chats can be renamed, archived or deleted.
  void onChatMore(ChatSummary chat) {}

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    search.dispose();
    super.onClose();
  }
}
