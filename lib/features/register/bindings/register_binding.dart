import 'package:get/get.dart';

import 'package:aurenix/features/register/controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
