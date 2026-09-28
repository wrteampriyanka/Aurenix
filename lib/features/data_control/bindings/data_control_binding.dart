import 'package:get/get.dart';

import '../controllers/data_control_controller.dart';

class DataControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataControlController>(() => DataControlController());
  }
}
