import 'package:get/get.dart';

import 'package:aurenix/features/data_control/controllers/data_control_controller.dart';

class DataControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataControlController>(() => DataControlController());
  }
}
