import 'package:get/get.dart';

import 'package:aurenix/features/collaboration/controllers/collaboration_controller.dart';
import 'package:aurenix/features/home/models/project.dart';

class CollaborationBinding extends Bindings {
  @override
  void dependencies() {
    // Opened without a project — on web that is just typing the path in the
    // URL bar. The controller redirects instead of casting and throwing.
    final args = Get.arguments;
    final project = args is Project ? args : null;
    Get.lazyPut<CollaborationController>(
      () => CollaborationController(projectId: project?.id),
    );
  }
}
