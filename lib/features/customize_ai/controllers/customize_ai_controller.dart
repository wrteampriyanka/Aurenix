import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

class CustomizeAiController extends GetxController {
  static const personalityKeys = [
    'ai_personality_default',
    'ai_personality_friendly',
    'ai_personality_professional',
    'ai_personality_concise',
  ];

  final instructionsController = TextEditingController();
  final nicknameController = TextEditingController();
  final occupationController = TextEditingController();
  final aboutController = TextEditingController();

  final isEnabled = true.obs;
  final personality = personalityKeys.first.obs;

  void onToggle(bool value) => isEnabled.value = value;

  void onPersonalityChanged(String? value) {
    if (value != null) personality.value = value;
  }

  void onMemories() => Get.toNamed(AppRoutes.memories);

  void onSave() {
    // TODO: persist the settings once the AI customization API is wired up.
    Get.back();
  }

  @override
  void onClose() {
    instructionsController.dispose();
    nicknameController.dispose();
    occupationController.dispose();
    aboutController.dispose();
    super.onClose();
  }
}
