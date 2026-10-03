import 'package:get/get.dart';

import '../../home/controllers/sidebar_controller.dart';
import '../controllers/project_detail_controller.dart';

class ProjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    final project = Get.arguments as Project;
    Get.lazyPut<ProjectDetailController>(
      () => ProjectDetailController(projectId: project.id),
    );
  }
}
