import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/sidebar_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SidebarController>(() => SidebarController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
