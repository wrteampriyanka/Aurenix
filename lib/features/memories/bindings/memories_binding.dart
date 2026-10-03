import 'package:get/get.dart';

import 'package:aurenix/features/memories/controllers/memories_controller.dart';

class MemoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoriesController>(() => MemoriesController());
  }
}
