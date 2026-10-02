import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../otp/controllers/otp_controller.dart';
import '../../widgets/bottom_sheets/forgot_password_sheet.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final forgotFormKey = GlobalKey<FormState>();
  final forgotEmailController = TextEditingController();

  final isPasswordHidden = true.obs;

  late final termsRecognizer = TapGestureRecognizer()..onTap = onTermsTap;
  late final privacyRecognizer = TapGestureRecognizer()..onTap = onPrivacyTap;
  late final registerRecognizer = TapGestureRecognizer()..onTap = onRegister;

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  void onRegister() => Get.toNamed(AppRoutes.register);

  void onLogin() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    // TODO: authenticate with email and password.
    _goHome();
  }

  // TODO: sign in with the provider before going home.
  void onGoogleLogin() => _goHome();
  void onGithubLogin() => _goHome();

  /// Clears the auth screens so back can't return to them.
  void _goHome() => Get.offAllNamed(AppRoutes.home);

  /// Opens the forgot password sheet, prefilled with the login email.
  void onForgotPassword() {
    forgotEmailController.text = emailController.text.trim();
    ForgotPasswordSheet.show();
  }

  void onStartVerification() {
    if (!(forgotFormKey.currentState?.validate() ?? false)) return;
    // TODO: request a password reset code for this email.
    Get.back();
    Get.toNamed(
      AppRoutes.otp,
      arguments: OtpArgs(
        email: forgotEmailController.text.trim(),
        purpose: OtpPurpose.resetPassword,
      ),
    );
  }

  // TODO: wire up the remaining actions once auth and routes exist.
  void onTermsTap() {}
  void onPrivacyTap() {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    termsRecognizer.dispose();
    privacyRecognizer.dispose();
    registerRecognizer.dispose();
    super.onClose();
  }
}
