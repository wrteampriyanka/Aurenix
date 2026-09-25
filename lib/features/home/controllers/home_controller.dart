import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import 'sidebar_controller.dart';

/// A quick action chip under the orb.
class HomeAction {
  const HomeAction({required this.labelKey, required this.icon});

  /// Translation key of the label.
  final String labelKey;

  /// SVG asset path of the coloured icon.
  final String icon;
}

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final messageController = TextEditingController();

  /// Sidebar drawer position: 0 closed, 1 open.
  late final drawer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  final isDrawerOpen = false.obs;

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

  @override
  void onInit() {
    super.onInit();
    drawer.addListener(() => isDrawerOpen.value = drawer.value > 0);
    // Picking a chat in the sidebar (or on search) shows it here.
    ever(Get.find<SidebarController>().selectedChatId, (_) => closeDrawer());
  }

  void onMenu() => drawer.isDismissed ? drawer.forward() : closeDrawer();

  void closeDrawer() => drawer.reverse();

  // TODO: wire these up once the chat and menus exist.
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
    drawer.dispose();
    super.onClose();
  }
}
