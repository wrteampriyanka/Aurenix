import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../models/upgrade_plan.dart';

class UpgradeController extends GetxController {
  List<UpgradePlan> get plans => UpgradePlan.all;

  void onDismiss() => Get.back();

  void onActivate(UpgradePlan plan) =>
      Get.toNamed(AppRoutes.checkout, arguments: plan);
}
