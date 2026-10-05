import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/widgets/message_menu.dart';
import 'package:aurenix/features/widgets/bottom_sheets/app_picker_sheet.dart';
import 'package:aurenix/features/widgets/bottom_sheets/create_project_sheet.dart';
import 'package:aurenix/features/widgets/bottom_sheets/project_instructions_sheet.dart';
import 'package:aurenix/features/widgets/bottom_sheets/project_menu_sheet.dart';
import 'package:aurenix/features/widgets/bottom_sheets/rename_chat_sheet.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/widgets/app_snackbar.dart';

/// What a sidebar menu row does when tapped.
enum SidebarAction { newChat, temporaryChat, presets, newProject, viewAll }

/// A row in one of the sidebar menu cards.
class SidebarItem {
  const SidebarItem({
    required this.action,
    required this.labelKey,
    this.icon,
    this.iconAsset,
    this.iconColor,
    this.showArrow = false,
  }) : assert(icon != null || iconAsset != null, 'give an icon or an asset');

  final SidebarAction action;

  /// Translation key of the label.
  final String labelKey;

  /// A font icon, or null when [iconAsset] is used instead.
  final IconData? icon;

  /// An SVG from `assets/images`, tinted like a font icon.
  final String? iconAsset;

  /// Tint of the icon; defaults to the regular text colour.
  final Color? iconColor;
  final bool showArrow;
}

/// A past conversation listed under "Chats".
class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.title,
    this.authorInitials,
    this.authorColor,
  });

  final String id;
  final String title;

  /// Initials of whoever started the chat, shown on the project screen;
  /// null for chats that are not in a shared project.
  final String? authorInitials;
  final Color? authorColor;

  ChatSummary copyWith({String? title}) => ChatSummary(
    id: id,
    title: title ?? this.title,
    authorInitials: authorInitials,
    authorColor: authorColor,
  );
}

/// A folder of chats, listed in the sidebar and on the projects screen.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.icon,
    required this.iconColor,
    this.memory = ProjectMemory.all,
    this.chatCount = 0,
    this.instructions = '',
  });

  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;

  /// How much of the user's history the project may draw on.
  final ProjectMemory memory;
  final int chatCount;

  /// What the assistant should keep in mind inside this project.
  final String instructions;

  Project copyWith({
    String? name,
    String? instructions,
    IconData? icon,
    Color? iconColor,
    int? chatCount,
  }) => Project(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    iconColor: iconColor ?? this.iconColor,
    memory: memory,
    chatCount: chatCount ?? this.chatCount,
    instructions: instructions ?? this.instructions,
  );
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
      iconAsset: AppAssets.addChatIcon,
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

  /// The chat on screen, or null when the conversation is a fresh one that
  /// has not earned a history entry yet.
  final selectedChatId = RxnString();

  /// What each chat in the list is made of, by id. Held for this app run
  /// only, until the API can store conversations.
  final _transcripts = <String, List<ChatMessage>>{};

  // TODO: drop these along with the seeded chats above once the API can
  // hand back real conversations.
  static const _demoTranscripts = {
    '1': [
      'Could several universes really hold different laws of physics?',
      'They could. In the inflationary picture each bubble universe cools '
          'into its own vacuum state, so constants we treat as fixed — the '
          'strength of gravity, the mass of an electron — settle at '
          'different values in each one. Most of those settings would never '
          'form stars or chemistry, which is why ours looks finely tuned '
          'from the inside.',
      'So where would the cosmic power in those stories come from?',
      'In fiction it is usually borrowed from the vacuum itself: the energy '
          'of empty space, which really is what drives the expansion we '
          'measure. The leap is the idea that a being could tap it locally '
          'and keep the result stable.',
    ],
    '2': [
      'What would actually happen if two universes touched?',
      'If two bubbles with different vacuum states met, the wall between '
          'them would not stay put — the lower-energy vacuum would eat into '
          'the higher one at close to the speed of light, rewriting the '
          'physics inside as it went. Nothing built out of the old constants '
          'would survive the crossing.',
      'That is grimmer than the comics make it look.',
      'Much grimmer. The comic version keeps both sets of matter intact so '
          'the characters can meet, which needs the walls to be stable — the '
          'one thing the physics does not give you.',
    ],
    '3': [
      'Is there any evidence for astral travel, or is it all subconscious?',
      'The experiences are real and well documented; the travel is not. '
          'Out-of-body episodes can be brought on in a lab by stimulating '
          'the temporoparietal junction, which is where the brain stitches '
          'touch, balance and vision into one sense of where you are. '
          'Disturb that and the self seems to sit outside the body.',
      'Why do the reports agree with each other so often?',
      'Because they come from the same machinery: the ceiling view, the '
          'floating, the tunnel all follow from how that region fails. '
          'Shared anatomy gives shared imagery without a shared destination.',
    ],
  };

  /// The project screen lists the same three conversations under its own
  /// ids, so they open to the same words.
  static const _demoAliases = {'pc1': '1', 'pc2': '2', 'pc3': '3'};

  /// Fills the seeded chats in, so opening one from the history shows its
  /// own conversation rather than an empty screen.
  void _seedTranscripts() {
    for (final entry in _demoTranscripts.entries) {
      _transcripts[entry.key] = [
        for (final (i, text) in entry.value.indexed)
          ChatMessage.history(isUser: i.isEven, text: text),
      ];
    }
    for (final entry in _demoAliases.entries) {
      _transcripts[entry.key] = _transcripts[entry.value]!;
    }
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
    if (line.isEmpty) return 'sidebar_new_chat'.tr;
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
    _seedTranscripts();
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
    _home.closeDrawer();
  }

  void onProfile() => Get.toNamed(AppRoutes.profile);

  HomeController get _home => Get.find<HomeController>();

  void onItem(SidebarItem item) {
    switch (item.action) {
      case SidebarAction.newChat:
        _startChat();
      case SidebarAction.temporaryChat:
        _startChat(temporary: true);
        AppSnackbar.show('sidebar_temporary_chat_on'.tr);
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
    _home.closeDrawer();
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
    _home.closeDrawer();
    Get.toNamed(AppRoutes.projectDetail, arguments: project);
  }

  /// The long-press menu on a project card or sidebar row.
  Future<void> onProjectMenu(Project project) async {
    HapticFeedback.mediumImpact();
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
        AppSnackbar.show('projects_import_coming_soon'.tr);
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
      'projects_deleted'.trParams({'name': project.name}),
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
        label: 'chat_menu_rename'.tr,
        onTap: () => renameChat(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.arrowCircleDown,
        label: 'chat_menu_archive'.tr,
        onTap: () => archiveChat(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.folderSimplePlus,
        label: 'chat_menu_move'.tr,
        onTap: () => moveChatToProject(chat),
      ),
      MessageMenuItem(
        icon: PhosphorIconsRegular.trash,
        label: 'chat_menu_delete'.tr,
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
    AppSnackbar.show('chat_menu_archived'.trParams({'name': chat.title}));
  }

  /// Files the chat under one of the user's projects, picked from a sheet.
  Future<void> moveChatToProject(ChatSummary chat) async {
    if (projects.isEmpty) {
      AppSnackbar.show('chat_menu_no_projects'.tr);
      return;
    }
    final project = await AppPickerSheet.show<Project>(
      title: 'chat_menu_move'.tr,
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
    AppSnackbar.show('chat_menu_moved'.trParams({'name': project.name}));
  }

  void deleteChat(ChatSummary chat) {
    _removeChat(chat);
    AppSnackbar.show('chat_menu_deleted'.trParams({'name': chat.title}));
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
