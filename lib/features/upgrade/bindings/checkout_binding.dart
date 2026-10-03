import 'package:get/get.dart';

import 'package:aurenix/features/upgrade/controllers/checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
