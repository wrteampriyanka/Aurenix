import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';

/// A quick action chip under the orb.
class HomeAction {
  const HomeAction({required this.labelKey, required this.icon});

  /// Translation key of the label.
  final String labelKey;

  /// SVG asset path of the coloured icon.
  final String icon;
}

class HomeController extends GetxController {
  final messageController = TextEditingController();

  static const actions = [
    HomeAction(labelKey: 'home_code', icon: AppAssets.codeIcon),
    HomeAction(labelKey: 'home_research', icon: AppAssets.researchIcon),
    HomeAction(labelKey: 'home_canvas', icon: AppAssets.canvasIcon),
    HomeAction(
      labelKey: 'home_generate_images',
      icon: AppAssets.generateImagesIcon,
    ),
    HomeAction(labelKey: 'home_integration', icon: AppAssets.integrationIcon),
  ];

  // TODO: wire these up once the chat and menus exist.
  void onMenu() {}
  void onModelTap() {}
  void onNewChat() {}
  void onMore() {}
  void onAction(HomeAction action) {}
  void onAttach() {}
  void onMic() {}
  void onVoice() {}

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
