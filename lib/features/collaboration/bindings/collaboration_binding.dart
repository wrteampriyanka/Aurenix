import 'package:get/get.dart';

import 'package:aurenix/ui/screens/home/controllers/sidebar_controller.dart';
import 'package:aurenix/ui/screens/collaboration/controllers/collaboration_controller.dart';

class CollaborationBinding extends Bindings {
  @override
  void dependencies() {
    final project = Get.arguments as Project;
    Get.lazyPut<CollaborationController>(
      () => CollaborationController(projectId: project.id),
    );
  }
}
