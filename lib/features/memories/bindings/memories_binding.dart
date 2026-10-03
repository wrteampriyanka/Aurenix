import 'package:get/get.dart';

import 'package:aurenix/ui/screens/memories/controllers/memories_controller.dart';

class MemoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoriesController>(() => MemoriesController());
  }
}
