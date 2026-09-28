import 'package:get/get.dart';

import '../controllers/customize_ai_controller.dart';

class CustomizeAiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeAiController>(() => CustomizeAiController());
  }
}
