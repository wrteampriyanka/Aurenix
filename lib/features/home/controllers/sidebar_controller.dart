import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/repositories/sidebar_repository.dart';
import 'package:aurenix/features/home/models/chat_message.dart';
import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/features/home/models/sidebar_item.dart';
import 'package:aurenix/features/home/widgets/message_menu.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/app_picker_sheet.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/create_project_sheet.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/project_instructions_sheet.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/project_menu_sheet.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/rename_chat_sheet.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/core/constants/app_strings.dart';

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

  /// The menu rows. Fixed UI, not data the API will serve.
  static const actions = [
    SidebarItem(
      action: SidebarAction.newChat,
      labelKey: AppStrings.sidebarNewChat,
      iconAsset: AppAssets.addChatIcon,
      showArrow: true,
    ),
    SidebarItem(
      action: SidebarAction.temporaryChat,
      labelKey: AppStrings.sidebarTemporaryChat,
      icon: PhosphorIconsRegular.chatCircle,
      showArrow: true,
    ),
    SidebarItem(
      action: SidebarAction.presets,
      labelKey: AppStrings.sidebarPresets,
      icon: PhosphorIconsRegular.lightning,
      showArrow: true,
    ),
  ];

  static const newProjectItem = SidebarItem(
    action: SidebarAction.newProject,
    labelKey: AppStrings.sidebarNewProject,
    icon: PhosphorIconsRegular.folderPlus,
  );

  static const viewAllItem = SidebarItem(
    action: SidebarAction.viewAll,
    labelKey: AppStrings.sidebarViewAll,
    icon: PhosphorIconsRegular.dotsThree,
    showArrow: true,
  );

  // TODO: load the user's projects once the API exists.

  /// How many projects the sidebar lists before "View All".
  static const sidebarProjectCount = 2;

  final _repository = const SidebarRepository();

  final projects = <Project>[].obs;
  final chats = <ChatSummary>[].obs;

  /// The chat on screen, or null when the conversation is a fresh one that
  /// has not earned a history entry yet.
  final selectedChatId = RxnString();

  /// What each chat in the list is made of, by id. Held for this app run
  /// only, until the API can store conversations.
  final _transcripts = <String, List<ChatMessage>>{};

  /// Loads the drawer's content. The stored transcripts come with it, so
  /// opening a chat from the history shows its own conversation rather than
  /// an empty screen.
  Future<void> _load() async {
    projects.value = await _repository.projects();
    chats.value = await _repository.chats();
    _transcripts.addAll(await _repository.transcripts());
  }

  /// Longest a title taken from a first message runs before it is cut.
  static const _titleLength = 38;

  /// Files the conversation under the open chat, the way a chat app does:
  /// the first message of a new conversation opens an entry at the top of
  /// the list named after it, and every message after that updates it.
  void recordChat(List<ChatMessage> messages, String firstMessage) {
    if (messages.isEmpty) return;
    final title = _titleFrom(firstMessage);
    var id = selectedChatId.value;
    final index = id == null ? -1 : chats.indexWhere((c) => c.id == id);
    if (index == -1) {
      id = DateTime.now().microsecondsSinceEpoch.toString();
      chats.insert(0, ChatSummary(id: id, title: title));
      selectedChatId.value = id;
    } else if (!_transcripts.containsKey(id)) {
      // An entry that has no words of its own yet is named by this message.
      chats[index] = chats[index].copyWith(title: title);
    }
    // The messages themselves are shared, so a reply still streaming in
    // keeps filling out the stored copy.
    _transcripts[id!] = List.of(messages);
  }

  /// The messages of the chat with [id]; empty for one with nothing stored.
  List<ChatMessage> transcriptOf(String id) => _transcripts[id] ?? const [];

  /// A chat's name taken from its first message: one line, cut short.
  String _titleFrom(String text) {
    final line = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (line.isEmpty) return AppStrings.sidebarNewChat.tr;
    if (line.length <= _titleLength) return line;
    return '${line.substring(0, _titleLength).trimRight()}…';
  }

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
    _load();
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

  /// Selects [chat] and puts its messages back on screen; the home screen
  /// closes the drawer to show it.
  void onChat(ChatSummary chat) {
    selectedChatId.value = chat.id;
    _home.openChat(transcriptOf(chat.id));
    if (isSearching.value) onSearchBack();
    // Tapping the chat already on screen leaves the id alone, so the
    // drawer is closed here rather than off the back of a change to it.
    _home.drawer.close();
  }

  void onProfile() => Get.toNamed(AppRoutes.profile);

  HomeController get _home => Get.find<HomeController>();

  void onItem(SidebarItem item) {
    switch (item.action) {
      case SidebarAction.newChat:
        _startChat();
      case SidebarAction.temporaryChat:
        _startChat(temporary: true);
        AppSnackbar.show(AppStrings.sidebarTemporaryChatOn.tr);
      case SidebarAction.presets:
        Get.toNamed(AppRoutes.presets);
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
    _home.drawer.close();
  }

  /// Guards against opening two sheets at the same time.
  bool _isCreatingProject = false;

  /// Walks the user through the create-project steps and adds the result to
  /// the top of the list.
  Future<void> onCreateProject() async {
    if (_isCreatingProject) return;
    _isCreatingProject = true;
    final draft = await CreateProjectSheet.show();
    _isCreatingProject = false;
    if (draft == null) return;
    projects.insert(
      0,
      Project(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: draft.name,
        icon: draft.icon,
        iconColor: draft.iconColor,
        memory: draft.memory,
      ),
    );
  }

  /// Opens [project]'s own screen, with its chats and composer.
  void onProject(Project project) {
    _home.drawer.close();
    Get.toNamed(AppRoutes.projectDetail, arguments: project);
  }

  /// The long-press menu on a project card or sidebar row.
  Future<void> onProjectMenu(Project project) async {
    unawaited(HapticFeedback.mediumImpact());
    final action = await ProjectMenuSheet.show();
    if (action == null) return;
    switch (action) {
      // Edit reopens the create sheet over the project: its name, colour
      // and icon. Instructions is the separate text sheet.
      case ProjectMenuAction.edit:
        await editProject(project);
      case ProjectMenuAction.instructions:
        await editInstructions(project);
      // TODO: wire this up once chats can be moved into a project.
      case ProjectMenuAction.importChats:
        AppSnackbar.show(AppStrings.projectsImportComingSoon.tr);
      case ProjectMenuAction.delete:
        deleteProject(project);
    }
  }

  /// Reopens the create sheet on the project's look, and keeps whatever
  /// comes back.
  Future<void> editProject(Project project) async {
    final draft = await CreateProjectSheet.edit(
      ProjectDraft(
        name: project.name,
        icon: project.icon,
        iconColor: project.iconColor,
        memory: project.memory,
      ),
    );
    if (draft == null) return;
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index == -1) return;
    projects[index] = projects[index].copyWith(
      name: draft.name,
      icon: draft.icon,
      iconColor: draft.iconColor,
    );
  }

  Future<void> editInstructions(Project project) async {
    final text = await ProjectInstructionsSheet.show(
      initialText: project.instructions,
    );
    if (text == null) return;
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index == -1) return;
    projects[index] = projects[index].copyWith(instructions: text);
  }

  void deleteProject(Project project) {
    projects.removeWhere((p) => p.id == project.id);
    AppSnackbar.show(
      AppStrings.projectsDeleted.trParams({'name': project.name}),
      duration: const Duration(seconds: 2),
    );
  }

  /// The chat the top bar's "..." acts on: whichever one is open.
  ChatSummary? get selectedChat {
    final id = selectedChatId.value;
    if (id == null) return null;
    final index = chats.indexWhere((c) => c.id == id);
    return index == -1 ? null : chats[index];
  }

  /// The Rename / Archive / Move / Delete card, grown out of [anchor].
  Future<void> showChatMenu({
    required BuildContext context,
    required Rect anchor,
    required ChatSummary chat,
  }) => showMessageMenu(
    context: context,
    anchor: anchor,
    items: [
      MessageMenuItem(
        icon: PhosphorIconsRegular.pencilSimple,
        label: AppStrings.chatMenuRename.tr,
        onTap: () => renameChat(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.arrowCircleDown,
        label: AppStrings.chatMenuArchive.tr,
        onTap: () => archiveChat(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.folderSimplePlus,
        label: AppStrings.chatMenuMove.tr,
        onTap: () => moveChatToProject(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.trash,
        label: AppStrings.chatMenuDelete.tr,
        onTap: () => deleteChat(chat),
      ),
    ],
  );

  /// Opens the title in a sheet and keeps whatever comes back.
  Future<void> renameChat(ChatSummary chat) async {
    final title = await RenameChatSheet.show(initialTitle: chat.title);
    if (title == null) return;
    final index = chats.indexWhere((c) => c.id == chat.id);
    if (index == -1) return;
    chats[index] = chats[index].copyWith(title: title);
  }

  // TODO: sync these three with the API; for now they only move the chat
  // out of the drawer's list.
  void archiveChat(ChatSummary chat) {
    _removeChat(chat);
    AppSnackbar.show(
      AppStrings.chatMenuArchived.trParams({'name': chat.title}),
    );
  }

  /// Files the chat under one of the user's projects, picked from a sheet.
  Future<void> moveChatToProject(ChatSummary chat) async {
    if (projects.isEmpty) {
      AppSnackbar.show(AppStrings.chatMenuNoProjects.tr);
      return;
    }
    final project = await AppPickerSheet.show<Project>(
      title: AppStrings.chatMenuMove.tr,
      items: projects,
      labelOf: (p) => p.name,
    );
    if (project == null) return;
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = projects[index].copyWith(
        chatCount: projects[index].chatCount + 1,
      );
    }
    _removeChat(chat);
    AppSnackbar.show(AppStrings.chatMenuMoved.trParams({'name': project.name}));
  }

  void deleteChat(ChatSummary chat) {
    _removeChat(chat);
    AppSnackbar.show(AppStrings.chatMenuDeleted.trParams({'name': chat.title}));
  }

  /// Drops the chat from the drawer, starting a fresh one when it was the
  /// conversation on screen.
  void _removeChat(ChatSummary chat) {
    chats.removeWhere((c) => c.id == chat.id);
    _transcripts.remove(chat.id);
    if (selectedChatId.value == chat.id) _startChat();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchFocus.dispose();
    search.dispose();
    super.onClose();
  }
}
