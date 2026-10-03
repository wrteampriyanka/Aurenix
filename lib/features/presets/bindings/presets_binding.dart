import 'package:get/get.dart';

import 'package:aurenix/ui/screens/presets/controllers/presets_controller.dart';

class PresetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresetsController>(() => PresetsController());
  }
}
