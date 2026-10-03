import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';

/// The preset opened from the Presets list, passed as the route argument.
class PresetDetailController extends GetxController {
  late final Preset preset;

  /// Tag of the list card that flies into the header card.
  late final String heroTag;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PresetDetailArgs) {
      preset = args.preset;
      heroTag = args.heroTag;
    } else {
      preset = PresetsController.presets.first;
      heroTag = preset.id;
    }
  }

  Future<void> onVisitSite() => openPresetSite(preset);

  /// Opens a chat with this preset on the home screen, with [starter]
  /// typed into the input if given.
  ///
  /// The Presets list sits between this page and home. It is dropped
  /// without animation first, so this page closes straight onto the chat
  /// instead of the list showing through on the way.
  void onStartChat([String? starter]) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().startPreset(preset, starter);
    }
    final list = Get.isRegistered<PresetsController>()
        ? Get.find<PresetsController>().route
        : null;
    if (list != null && Get.currentRoute == AppRoutes.presetDetail) {
      Get.removeRoute(list);
      Get.back();
      return;
    }
    Get.until((route) => route.settings.name == AppRoutes.home);
  }
}
