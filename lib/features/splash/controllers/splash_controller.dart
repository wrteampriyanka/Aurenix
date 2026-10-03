import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/session_service.dart';

class SplashController extends GetxController {
  static const Duration _splashDuration = Duration(seconds: 2);

  /// Where the app opens: straight into the chat for someone already signed
  /// in, otherwise back to sign in, and onboarding only on a first run.
  String get _nextRoute {
    final session = SessionService.instance;
    if (session.isSignedIn) return AppRoutes.home;
    return session.hasOnboarded ? AppRoutes.login : AppRoutes.onboarding;
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(_splashDuration, () => Get.offAllNamed(_nextRoute));
  }
}
