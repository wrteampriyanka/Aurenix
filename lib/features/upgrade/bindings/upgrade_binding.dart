import 'package:get/get.dart';

import 'package:aurenix/features/upgrade/controllers/upgrade_controller.dart';

class UpgradeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpgradeController>(() => UpgradeController());
  }
}
