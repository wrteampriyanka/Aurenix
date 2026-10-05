import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/features/widgets/app_snackbar.dart';
import 'package:aurenix/features/widgets/bottom_sheets/project_files_sheet.dart';

/// One project's chats, opened by tapping a project card or sidebar row.
/// The project itself lives in [SidebarController], so renaming or deleting
/// it there is reflected here.
class ProjectDetailController extends GetxController {
  ProjectDetailController({required this.projectId});

  final String projectId;

  final _sidebar = Get.find<SidebarController>();

  final searchController = TextEditingController();
  final query = ''.obs;

  /// The project, or null once it has been deleted. Read inside an [Obx] it
  /// also rebuilds when the project is renamed.
  Project? get project =>
      _sidebar.projects.firstWhereOrNull((p) => p.id == projectId);

  // TODO: load the project's own chats once chats can be stored by project.
  final chats = <ChatSummary>[
    const ChatSummary(
      id: 'pc1',
      title: 'Multiverse & Cosmic Power',
      authorInitials: 'MS',
      authorColor: Color(0xFF2563EB),
    ),
    const ChatSummary(
      id: 'pc2',
      title: 'Branched - Incursion of tow universes',
      authorInitials: 'AL',
      authorColor: Color(0xFFB45309),
    ),
    const ChatSummary(
      id: 'pc3',
      title: 'Astral travel & Subconscious',
      authorInitials: 'RM',
      authorColor: Color(0xFF0F766E),
    ),
  ].obs;

  /// Chats whose title contains the search query.
  List<ChatSummary> get filteredChats {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  // TODO: load and upload the project's files once the backend stores them.
  final files = <ProjectFile>[
    const ProjectFile(id: 'pf1', name: 'Universe Study Doc 3', bytes: 23 << 20),
    const ProjectFile(
      id: 'pf2',
      name: 'Warm Hole - Research Paper',
      bytes: 103 << 20,
    ),
    const ProjectFile(
      id: 'pf3',
      name: 'Paper Universe Theory',
      bytes: 11 << 20,
    ),
    const ProjectFile(
      id: 'pf4',
      name: 'Project Question Entanglement',
      bytes: 493 << 20,
    ),
  ].obs;

  final messageController = TextEditingController();
  final hasText = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
    messageController.addListener(
      () => hasText.value = messageController.text.trim().isNotEmpty,
    );
  }

  /// Opens [chat] back on the home screen.
  void onChat(ChatSummary chat) {
    _backToHome();
    _sidebar.onChat(chat);
  }

  // TODO: wire this up once chats can be renamed, archived or deleted.
  void onChatMore(ChatSummary chat) {}

  Future<void> onMenu() async {
    if (project case final p?) await _sidebar.onProjectMenu(p);
    // The menu can delete the project; there is nothing left to show then.
    if (project == null) Get.back();
  }

  Future<void> onInstructions() async {
    if (project case final p?) await _sidebar.editInstructions(p);
  }

  /// Shows the project's files, with a button to upload more.
  void onFiles() {
    ProjectFilesSheet.show(
      files: files,
      onUpload: onUploadFiles,
      onRemove: files.remove,
    );
  }

  /// Adds whatever files the user picks to the project.
  Future<void> onUploadFiles() async {
    try {
      final picked = await FilePicker.pickFiles();
      for (final file in picked) {
        files.add(
          ProjectFile(
            id: '${DateTime.now().microsecondsSinceEpoch}-${file.name}',
            name: file.name,
            bytes: file.lengthSync() ?? await file.length() ?? 0,
          ),
        );
      }
    } catch (_) {
      AppSnackbar.error('project_files_failed'.tr);
    }
  }

  /// Opens the project's sharing settings.
  void onShare() {
    if (project case final p?) {
      Get.toNamed(AppRoutes.collaboration, arguments: p);
    }
  }

  /// Starts a chat in this project with whatever has been typed.
  void onSend() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    final home = Get.find<HomeController>();
    _backToHome();
    home.onNewChat();
    home.messageController.text = text;
    home.onSend();
  }

  void onVoice() => Get.toNamed(AppRoutes.liveTalk);

  void _backToHome() {
    Get.until((route) => route.settings.name == AppRoutes.home);
    Get.find<HomeController>().closeDrawer();
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
