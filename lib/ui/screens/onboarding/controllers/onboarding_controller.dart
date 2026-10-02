import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  void onGetStarted() => Get.offAllNamed(AppRoutes.login);
}
