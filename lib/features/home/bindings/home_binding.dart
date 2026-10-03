import 'package:get/get.dart';

import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SidebarController>(() => SidebarController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
