import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../home/controllers/sidebar_controller.dart';
import '../../widgets/app_snackbar.dart';

/// Who can open the project.
enum ProjectAccess { onlyInvited, anyoneWithLink }

/// What a collaborator may do. The owner's role cannot be changed.
enum CollaboratorRole { owner, canEdit, viewOnly }

/// Someone the project is shared with.
class Collaborator {
  const Collaborator({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String initials;
  final Color color;
  final CollaboratorRole role;

  Collaborator copyWith({CollaboratorRole? role}) => Collaborator(
    id: id,
    name: name,
    email: email,
    initials: initials,
    color: color,
    role: role ?? this.role,
  );
}

/// Sharing settings for one project: who may open it, who is on it, and
/// the invite link.
class CollaborationController extends GetxController {
  CollaborationController({required this.projectId});

  final String projectId;

  final _sidebar = Get.find<SidebarController>();

  Project? get project =>
      _sidebar.projects.firstWhereOrNull((p) => p.id == projectId);

  final emailController = TextEditingController();
  final canInvite = false.obs;

  final access = ProjectAccess.onlyInvited.obs;

  // TODO: load the project's collaborators once sharing exists.
  final members = <Collaborator>[
    Collaborator(
      id: 'm1',
      name: 'collaboration_you'.tr,
      email: 'designer@gmail.com',
      initials: 'MS',
      color: const Color(0xFF2563EB),
      role: CollaboratorRole.owner,
    ),
    const Collaborator(
      id: 'm2',
      name: 'Alex',
      email: 'alaxy322@gmail.com',
      initials: 'AL',
      color: Color(0xFFB45309),
      role: CollaboratorRole.viewOnly,
    ),
    const Collaborator(
      id: 'm3',
      name: 'Rubina maria',
      email: 'rubbyspot443@gmail.com',
      initials: 'RM',
      color: Color(0xFF0F766E),
      role: CollaboratorRole.canEdit,
    ),
  ].obs;

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void onInit() {
    super.onInit();
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
      AppSnackbar.error('collaboration_invalid_email'.tr);
      return;
    }
    if (members.any((m) => m.email.toLowerCase() == email.toLowerCase())) {
      AppSnackbar.error('collaboration_already_member'.tr);
      return;
    }
    final name = email.split('@').first;
    members.add(
      Collaborator(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        email: email,
        initials: _initials(name),
        color: _colors[members.length % _colors.length],
        role: CollaboratorRole.viewOnly,
      ),
    );
    emailController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    AppSnackbar.show(
      'collaboration_invited'.trParams({'email': email}),
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
      'collaboration_removed'.trParams({'name': member.name}),
      duration: const Duration(seconds: 2),
    );
  }

  // TODO: use the real invite link once the API exists.
  Future<void> onShareLink() async {
    await Clipboard.setData(
      ClipboardData(text: 'https://aurenix.app/p/$projectId'),
    );
    AppSnackbar.show('collaboration_link_copied'.tr);
  }

  static const _colors = [
    Color(0xFF2563EB),
    Color(0xFFB45309),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFBE123C),
  ];

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'[\s._-]+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
