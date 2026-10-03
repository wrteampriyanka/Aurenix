import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/ui/screens/upgrade/models/upgrade_plan.dart';

class UpgradeController extends GetxController {
  List<UpgradePlan> get plans => UpgradePlan.all;

  void onDismiss() => Get.back();

  void onActivate(UpgradePlan plan) =>
      Get.toNamed(AppRoutes.checkout, arguments: plan);
}
