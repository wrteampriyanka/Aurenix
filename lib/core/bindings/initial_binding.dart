import 'package:get/get.dart';

import 'package:aurenix/features/home/controllers/sidebar_controller.dart';

/// Registered before the first route is built.
///
/// [SidebarController] holds the projects and chats the whole app reads, and
/// five controllers `Get.find` it. Registering it per-screen meant a route
/// opened directly — on web, by typing its path — threw before its screen
/// ever built. It lives for the life of the app, so it is put once here.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SidebarController>(SidebarController(), permanent: true);
  }
}
