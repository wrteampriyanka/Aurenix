import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/features/collaboration/models/collaborator.dart';
import 'package:aurenix/features/collaboration/repositories/collaboration_repository.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Sharing settings for one project: who may open it, who is on it, and
/// the invite link.
class CollaborationController extends GetxController {
  CollaborationController({required this.projectId});

  /// Null when the route was opened without a project argument.
  final String? projectId;

  final _repository = const CollaborationRepository();

  final _sidebar = Get.find<SidebarController>();

  Project? get project =>
      _sidebar.projects.firstWhereOrNull((p) => p.id == projectId);

  final emailController = TextEditingController();
  final canInvite = false.obs;

  final access = ProjectAccess.onlyInvited.obs;

  final members = <Collaborator>[].obs;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

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
    emailController.addListener(
      () =>
          canInvite.value = _emailPattern.hasMatch(emailController.text.trim()),
    );
  }

  void onAccess(ProjectAccess value) => access.value = value;

  /// Invites whoever is in the email field, as a viewer to start with.
  void onInvite() {
    final email = emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      AppSnackbar.error(AppStrings.collaborationInvalidEmail.tr);
      return;
    }
    if (members.any((m) => m.email.toLowerCase() == email.toLowerCase())) {
      AppSnackbar.error(AppStrings.collaborationAlreadyMember.tr);
      return;
    }
    final name = email.split('@').first;
    members.add(
      Collaborator(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        email: email,
        initials: _initials(name),
        color: appColors
            .avatarSwatch[members.length % appColors.avatarSwatch.length],
        role: CollaboratorRole.viewOnly,
      ),
    );
    emailController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    AppSnackbar.show(
      AppStrings.collaborationInvited.trParams({'email': email}),
      duration: const Duration(seconds: 2),
    );
  }

  void onRole(Collaborator member, CollaboratorRole role) {
    final index = members.indexWhere((m) => m.id == member.id);
    if (index == -1) return;
    members[index] = members[index].copyWith(role: role);
  }

  void onRemove(Collaborator member) {
    members.removeWhere((m) => m.id == member.id);
    AppSnackbar.show(
      AppStrings.collaborationRemoved.trParams({'name': member.name}),
      duration: const Duration(seconds: 2),
    );
  }

  // TODO: use the real invite link once the API exists.
  Future<void> onShareLink() async {
    await Clipboard.setData(
      ClipboardData(text: 'https://aurenix.app/p/$projectId'),
    );
    AppSnackbar.show(AppStrings.collaborationLinkCopied.tr);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'[\s._-]+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  Future<void> _load() async {
    members.value = await _repository.members(projectId!);
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
