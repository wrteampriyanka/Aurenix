import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../otp/controllers/otp_controller.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;

  late final termsRecognizer = TapGestureRecognizer()..onTap = onTermsTap;
  late final privacyRecognizer = TapGestureRecognizer()..onTap = onPrivacyTap;
  late final signInRecognizer = TapGestureRecognizer()..onTap = onSignIn;

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  void onCreateAccount() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    // TODO: create the account with name, email and password.
    Get.toNamed(
      AppRoutes.otp,
      arguments: OtpArgs(
        email: emailController.text.trim(),
        purpose: OtpPurpose.register,
      ),
    );
  }

  /// Returns to the login screen, reusing it if it is already on the stack.
  void onSignIn() {
    if (Get.previousRoute == AppRoutes.login) {
      Get.back();
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  // TODO: sign up with the provider before going home.
  void onGoogleSignUp() => Get.offAllNamed(AppRoutes.home);
  void onGithubSignUp() => Get.offAllNamed(AppRoutes.home);

  // TODO: wire up the remaining actions once auth exists.
  void onTermsTap() {}
  void onPrivacyTap() {}

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    termsRecognizer.dispose();
    privacyRecognizer.dispose();
    signInRecognizer.dispose();
    super.onClose();
  }
}
