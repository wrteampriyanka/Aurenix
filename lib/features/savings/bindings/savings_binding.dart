import 'package:get/get.dart';

import 'package:aurenix/ui/screens/savings/controllers/savings_controller.dart';

class SavingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SavingsController>(() => SavingsController());
  }
}
