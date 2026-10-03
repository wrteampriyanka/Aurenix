import 'package:get/get.dart';

import 'package:aurenix/features/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager: the view never reads `controller`, so lazyPut would never
    // create it and onReady (which navigates away) would never fire.
    Get.put<SplashController>(SplashController());
  }
}
