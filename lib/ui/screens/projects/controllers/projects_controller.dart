import 'package:get/get.dart';

import '../../home/controllers/sidebar_controller.dart';

/// All of the user's projects. The list lives in [SidebarController], which
/// stays alive under this screen, so new projects show in the sidebar too.
class ProjectsController extends GetxController {
  final _sidebar = Get.find<SidebarController>();

  RxList<Project> get projects => _sidebar.projects;

  void onCreate() => _sidebar.onCreateProject();

  void onProject(Project project) => _sidebar.onProject(project);
}
