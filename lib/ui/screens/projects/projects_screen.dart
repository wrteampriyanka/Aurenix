import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/app_plain_background.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/home/controllers/sidebar_controller.dart';
import '../../../features/projects/controllers/projects_controller.dart';

class ProjectsScreen extends GetView<ProjectsController> {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'projects_title'.tr,
      action: _CreateButton(onTap: controller.onCreate),
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final projects = controller.projects;
        if (projects.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 32),
            child: CustomText(
              'projects_empty'.tr,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: context.color.textBody,
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
    final color = context.color;
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
              const SizedBox(width: 8),
              CustomText(
                'projects_create_new'.tr,
                fontSize: 13,
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
  const _ProjectCard({required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Material(
      color: color.inputFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.tileBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                    child: CustomText(
                      project.name,
                      maxLines: 1,
                      fontSize: 14,
                      color: color.textNatural,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CustomText(
                'projects_chats'.trParams({'count': '${project.chatCount}'}),
                fontSize: 12,
                color: color.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
