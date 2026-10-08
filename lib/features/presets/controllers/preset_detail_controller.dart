import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/features/presets/models/preset_group.dart';

/// The preset opened from the Presets list, passed as the route argument.
class PresetDetailController extends GetxController {
  /// Null when the route was opened without a preset argument. The catalogue
  /// is loaded asynchronously now, so there is nothing to fall back on here.
  Preset? preset;

  /// Tag of the list card that flies into the header card.
  String heroTag = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! PresetDetailArgs) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Get.offNamed(AppRoutes.presets),
      );
      return;
    }
    preset = args.preset;
    heroTag = args.heroTag;
  }

  Future<void> onVisitSite() async {
    final p = preset;
    if (p != null) await openPresetSite(p);
  }

  /// Opens a chat with this preset on the home screen, with [starter]
  /// typed into the input if given.
  ///
  /// The Presets list sits between this page and home. It is dropped
  /// without animation first, so this page closes straight onto the chat
  /// instead of the list showing through on the way.
  void onStartChat([String? starter]) {
    final p = preset;
    if (p == null) return;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().startPreset(p, starter);
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
