import 'package:get/get.dart';

import 'package:aurenix/features/live_talk/controllers/live_talk_controller.dart';

class LiveTalkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveTalkController>(() => LiveTalkController());
  }
}
