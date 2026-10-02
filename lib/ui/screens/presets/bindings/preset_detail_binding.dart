import 'package:get/get.dart';

import '../controllers/preset_detail_controller.dart';

class PresetDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresetDetailController>(() => PresetDetailController());
  }
}
