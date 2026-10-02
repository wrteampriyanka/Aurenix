import 'package:get/get.dart';

import '../controllers/voice_settings_controller.dart';

class VoiceSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VoiceSettingsController>(() => VoiceSettingsController());
  }
}
