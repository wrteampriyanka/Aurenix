import 'package:get/get.dart';

import 'package:aurenix/ui/screens/home/controllers/sidebar_controller.dart';
import 'package:aurenix/ui/screens/project_detail/controllers/project_detail_controller.dart';

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    final project = Get.arguments as Project;
    Get.lazyPut<ProjectDetailController>(
      () => ProjectDetailController(projectId: project.id),
    );
  }
}
