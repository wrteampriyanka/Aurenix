import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// What the user picked from a project's long-press menu.
enum ProjectMenuAction { edit, instructions, importChats, delete }

/// The menu a project opens on long press: four plain rows, the last one
/// destructive. Resolves with the action tapped, or null when dismissed.
class ProjectMenuSheet extends StatelessWidget {
  const ProjectMenuSheet({super.key});

  static Future<ProjectMenuAction?> show() {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<ProjectMenuAction>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 380),
        reverseDuration: Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const ProjectMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: color.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.tileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: color.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _Row(
              icon: PhosphorIconsRegular.pencilSimple,
              label: AppStrings.projectsMenuEdit.tr,
              action: ProjectMenuAction.edit,
            ),
            _Row(
              icon: PhosphorIconsRegular.slidersHorizontal,
              label: AppStrings.projectsMenuInstructions.tr,
              action: ProjectMenuAction.instructions,
            ),
            _Row(
              icon: PhosphorIconsRegular.arrowCircleDown,
              label: AppStrings.projectsMenuImportChats.tr,
              action: ProjectMenuAction.importChats,
            ),
            _Row(
              icon: PhosphorIconsRegular.trash,
              label: AppStrings.projectsMenuDelete.tr,
              action: ProjectMenuAction.delete,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.action});

  final IconData icon;
  final String label;
  final ProjectMenuAction action;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color.textNatural),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppText(
                  label,
                  maxLines: 1,
                  fontSize: AppFontSize.body,
                  color: color.textNatural,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
