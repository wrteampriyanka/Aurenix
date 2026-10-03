import 'package:get/get.dart';

import 'package:aurenix/features/presets/controllers/preset_detail_controller.dart';

class PresetDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresetDetailController>(() => PresetDetailController());
  }
}
