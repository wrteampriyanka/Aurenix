import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/projects/controllers/projects_controller.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class ProjectsScreen extends GetView<ProjectsController> {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.projectsTitle.tr,
      action: _CreateButton(onTap: controller.onCreate),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Obx(() {
        final projects = controller.projects;
        if (projects.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 32),
            child: AppText(
              AppStrings.projectsEmpty.tr,
              fontSize: AppFontSize.label,
              textAlign: TextAlign.center,
              color: appColors.textBody,
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 76,
          ),
          itemCount: projects.length,
          itemBuilder: (_, i) => _ProjectCard(
            project: projects[i],
            onTap: () => controller.onProject(projects[i]),
            onLongPress: () => controller.onProjectMenu(projects[i]),
          ),
        );
      }),
    );
  }
}

/// Outlined "Create New" pill at the end of the app bar.
class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.inputFill,
      shape: StadiumBorder(side: BorderSide(color: color.tileBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.folderPlus,
                size: 18,
                color: color.textNatural,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                AppStrings.projectsCreateNew.tr,
                fontSize: AppFontSize.caption,
                color: color.textNatural,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onLongPress,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.inputFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.tileBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(project.icon, size: 20, color: project.iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      project.name,
                      maxLines: 1,
                      fontSize: AppFontSize.label,
                      color: color.textNatural,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppText(
                AppStrings.projectsChats.trParams({
                  'count': '${project.chatCount}',
                }),
                fontSize: AppFontSize.overline,
                color: color.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
