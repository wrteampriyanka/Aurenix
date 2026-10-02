import 'package:get/get.dart';

import '../controllers/presets_controller.dart';

class PresetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresetsController>(() => PresetsController());
  }
}
