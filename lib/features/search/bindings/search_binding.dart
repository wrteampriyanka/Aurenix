import 'package:get/get.dart';

import '../../home/controllers/sidebar_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // Normally already registered by the home screen underneath.
    Get.lazyPut<SidebarController>(() => SidebarController());
  }
}
