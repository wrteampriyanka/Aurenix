import 'package:get/get.dart';

import 'package:aurenix/ui/screens/upgrade/controllers/upgrade_controller.dart';

class UpgradeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpgradeController>(() => UpgradeController());
  }
}
