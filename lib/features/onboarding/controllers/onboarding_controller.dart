import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/session_service.dart';

class OnboardingController extends GetxController {
  Future<void> onGetStarted() async {
    // Seen once is enough: later launches go straight to sign in.
    await SessionService.instance.markOnboarded();
    Get.offAllNamed(AppRoutes.login);
  }
}
