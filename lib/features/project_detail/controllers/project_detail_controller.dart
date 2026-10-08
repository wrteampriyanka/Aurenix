import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/project_files_sheet.dart';
import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/features/project_detail/repositories/project_detail_repository.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// One project's chats, opened by tapping a project card or sidebar row.
/// The project itself lives in [SidebarController], so renaming or deleting
/// it there is reflected here.
class ProjectDetailController extends GetxController {
  ProjectDetailController({required this.projectId});

  /// Null when the route was opened without a project argument.
  final String? projectId;

  final _repository = const ProjectDetailRepository();

  final _sidebar = Get.find<SidebarController>();

  final searchController = TextEditingController();
  final query = ''.obs;

  /// The project, or null once it has been deleted. Read inside an [Obx] it
  /// also rebuilds when the project is renamed.
  Project? get project =>
      _sidebar.projects.firstWhereOrNull((p) => p.id == projectId);

  final chats = <ChatSummary>[].obs;

  /// Chats whose title contains the search query.
  List<ChatSummary> get filteredChats {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  final files = <ProjectFile>[].obs;

  final messageController = TextEditingController();
  final hasText = false.obs;

  @override
  void onInit() {
    super.onInit();

    // No project resolved — the route was opened without an argument, or the
    // project it named is gone. Nothing on this screen can render, so hand
    // the user the project list rather than an empty shell.
    if (project == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.offNamed(AppRoutes.projects),
      );
      return;
    }
    _load();
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
      AppSnackbar.error(AppStrings.projectFilesFailed.tr);
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
    Get.find<HomeController>().drawer.close();
  }

  Future<void> _load() async {
    final id = projectId!;
    chats.value = await _repository.chats(id);
    files.value = await _repository.files(id);
  }

  @override
  void onClose() {
    searchController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
