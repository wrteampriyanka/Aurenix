import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';

class SplashController extends GetxController {
  static const Duration _splashDuration = Duration(seconds: 2);

  @override
  void onReady() {
    super.onReady();
    Future.delayed(
      _splashDuration,
      () => Get.offAllNamed(AppRoutes.onboarding),
    );
  }
}
