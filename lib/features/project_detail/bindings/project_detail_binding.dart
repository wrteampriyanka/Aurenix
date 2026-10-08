import 'package:get/get.dart';

import 'package:aurenix/features/project_detail/controllers/project_detail_controller.dart';
import 'package:aurenix/features/home/models/project.dart';

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Opened without a project — on web that is just typing the path in the
    // URL bar. The controller redirects instead of casting and throwing.
    final args = Get.arguments;
    final project = args is Project ? args : null;
    Get.lazyPut<ProjectDetailController>(
      () => ProjectDetailController(projectId: project?.id),
    );
  }
}
