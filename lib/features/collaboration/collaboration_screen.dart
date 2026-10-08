import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/features/collaboration/controllers/collaboration_controller.dart';
import 'package:aurenix/features/collaboration/models/collaborator.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Who a project is shared with: its access setting, an invite field and
/// the list of members with their roles.
class CollaborationScreen extends GetView<CollaborationController> {
  const CollaborationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.collaborationTitle.tr,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      bottom: AppButton(
        label: AppStrings.collaborationShareLink.tr,
        icon: null,
        height: 52,
        fontSize: AppFontSize.body,
        onPressed: controller.onShareLink,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AccessTile(),
          const SizedBox(height: AppSpacing.xl),
          _Label(AppStrings.collaborationInviteLabel.tr),
          const SizedBox(height: AppSpacing.sm),
          _InviteRow(controller: controller),
          const SizedBox(height: AppSpacing.xl),
          _Label(AppStrings.collaborationMembersLabel.tr),
          const SizedBox(height: AppSpacing.sm),
          Obx(
            () => Column(
              children: [
                for (final member in controller.members)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MemberTile(
                      member: member,
                      onRole: (role) => controller.onRole(member, role),
                      onRemove: () => controller.onRemove(member),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small grey caption above a section.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      fontSize: AppFontSize.overline,
      color: appColors.textBody,
    );
  }
}

/// Who may open the project, as a tap-to-change row with a lock icon.
class _AccessTile extends GetView<CollaborationController> {
  const _AccessTile();

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.inputFill,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAccessMenu(context, controller),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.inputBorder),
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.lockSimple,
                size: 20,
                color: color.textNatural,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Obx(
                  () => AppText(
                    _accessLabel(controller.access.value),
                    maxLines: 1,
                    fontSize: AppFontSize.chat,
                    color: color.textNatural,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretDown,
                size: 18,
                color: color.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _accessLabel(ProjectAccess access) => switch (access) {
  ProjectAccess.onlyInvited => AppStrings.collaborationOnlyInvited.tr,
  ProjectAccess.anyoneWithLink => AppStrings.collaborationAnyoneWithLink.tr,
};

IconData _accessIcon(ProjectAccess access) => switch (access) {
  ProjectAccess.onlyInvited => PhosphorIconsRegular.lockSimpleOpen,
  ProjectAccess.anyoneWithLink => PhosphorIconsRegular.globeHemisphereWest,
};

/// Drops the access options out of the tile: a small caption over a dark
/// card with one row per option.
Future<void> _showAccessMenu(
  BuildContext context,
  CollaborationController controller,
) async {
  final tile = context.findRenderObject() as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final topLeft = tile.localToGlobal(Offset.zero, ancestor: overlay);
  final position = RelativeRect.fromLTRB(
    topLeft.dx,
    topLeft.dy + tile.size.height - 4,
    overlay.size.width - topLeft.dx - tile.size.width,
    0,
  );
  final picked = await showMenu<ProjectAccess>(
    context: context,
    position: position,
    color: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints.tightFor(width: tile.size.width),
    items: const [_AccessMenuEntry()],
  );
  if (picked != null) controller.onAccess(picked);
}

/// The whole access menu as one entry, so the caption can sit outside the
/// card the way the design has it.
class _AccessMenuEntry extends PopupMenuEntry<ProjectAccess> {
  const _AccessMenuEntry();

  @override
  double get height => 0;

  @override
  bool represents(ProjectAccess? value) => false;

  @override
  State<_AccessMenuEntry> createState() => _AccessMenuEntryState();
}

class _AccessMenuEntryState extends State<_AccessMenuEntry> {
  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: AppText(
            AppStrings.collaborationMenuTitle.tr,
            fontSize: AppFontSize.overline,
            color: color.textBody,
          ),
        ),
        Material(
          color: color.sheetCard,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final access in ProjectAccess.values)
                InkWell(
                  onTap: () => Navigator.pop(context, access),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _accessIcon(access),
                          size: 22,
                          color: color.textNatural,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppText(
                            _accessLabel(access),
                            maxLines: 1,
                            fontSize: AppFontSize.chat,
                            color: color.textNatural,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Email field with the round send button that invites.
class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.controller});

  final CollaborationController controller;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: color.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.inputBorder),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  PhosphorIconsRegular.envelopeSimple,
                  size: 20,
                  color: color.textBody,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.onInvite(),
                    cursorColor: color.primary,
                    style: TextStyle(
                      color: color.textNatural,
                      fontSize: AppFontSize.chat,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.collaborationEmailHint.tr,
                      hintStyle: TextStyle(
                        color: color.textBody,
                        fontSize: AppFontSize.chat,
                      ),
                      hintMaxLines: 1,
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Obx(
          () => Material(
            color: controller.canInvite.value
                ? color.primary
                : color.primary.withValues(alpha: 0.5),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: controller.onInvite,
              child: SizedBox.square(
                dimension: 52,
                child: Icon(
                  PhosphorIconsFill.paperPlaneTilt,
                  size: 20,
                  color: color.textOnPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One member: avatar, name and email, with their role at the end. The
/// owner's role is fixed, everyone else's opens a menu.
class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onRole,
    required this.onRemove,
  });

  final Collaborator member;
  final ValueChanged<CollaboratorRole> onRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Container(
      height: 64,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.tileBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: member.color,
              shape: BoxShape.circle,
            ),
            child: AppText(
              member.initials,
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: color.textNatural,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  member.name,
                  maxLines: 1,
                  fontSize: AppFontSize.chat,
                  color: color.textNatural,
                ),
                const SizedBox(height: 2),
                AppText(
                  member.email,
                  maxLines: 1,
                  fontSize: AppFontSize.overline,
                  color: color.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (member.role == CollaboratorRole.owner)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: AppText(
                roleLabel(member.role),
                fontSize: AppFontSize.caption,
                color: color.textBody,
              ),
            )
          else
            _RoleMenu(member: member, onRole: onRole, onRemove: onRemove),
        ],
      ),
    );
  }

  static String roleLabel(CollaboratorRole role) => switch (role) {
    CollaboratorRole.owner => AppStrings.collaborationRoleOwner.tr,
    CollaboratorRole.canEdit => AppStrings.collaborationRoleCanEdit.tr,
    CollaboratorRole.viewOnly => AppStrings.collaborationRoleViewOnly.tr,
  };
}

/// The role a member has, tappable for the change-role and remove options.
class _RoleMenu extends StatelessWidget {
  const _RoleMenu({
    required this.member,
    required this.onRole,
    required this.onRemove,
  });

  final Collaborator member;
  final ValueChanged<CollaboratorRole> onRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return PopupMenuButton<CollaboratorRole?>(
      onSelected: (role) => role == null ? onRemove() : onRole(role),
      padding: EdgeInsets.zero,
      color: color.sheetCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.tileBorder),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CollaboratorRole.canEdit,
          height: 44,
          child: AppText(
            _MemberTile.roleLabel(CollaboratorRole.canEdit),
            fontSize: AppFontSize.label,
            color: color.textNatural,
          ),
        ),
        PopupMenuItem(
          value: CollaboratorRole.viewOnly,
          height: 44,
          child: AppText(
            _MemberTile.roleLabel(CollaboratorRole.viewOnly),
            fontSize: AppFontSize.label,
            color: color.textNatural,
          ),
        ),
        PopupMenuItem(
          height: 44,
          child: AppText(
            AppStrings.collaborationRemove.tr,
            fontSize: AppFontSize.label,
            color: color.error,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              _MemberTile.roleLabel(member.role),
              fontSize: AppFontSize.caption,
              color: color.textBody,
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              PhosphorIconsRegular.caretDown,
              size: 14,
              color: color.textBody,
            ),
          ],
        ),
      ),
    );
  }
}
