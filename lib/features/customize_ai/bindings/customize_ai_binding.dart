import 'package:get/get.dart';

import 'package:aurenix/ui/screens/customize_ai/controllers/customize_ai_controller.dart';

class CustomizeAiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeAiController>(() => CustomizeAiController());
  }
}
