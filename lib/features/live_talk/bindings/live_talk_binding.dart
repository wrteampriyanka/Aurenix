import 'package:get/get.dart';

import '../controllers/live_talk_controller.dart';

class LiveTalkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveTalkController>(() => LiveTalkController());
  }
}
