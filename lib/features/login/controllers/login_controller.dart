import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/session_service.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/forgot_password_sheet.dart';
import 'package:aurenix/features/otp/models/otp_args.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final forgotFormKey = GlobalKey<FormState>();
  final forgotEmailController = TextEditingController();

  late final termsRecognizer = TapGestureRecognizer()..onTap = onTermsTap;
  late final privacyRecognizer = TapGestureRecognizer()..onTap = onPrivacyTap;
  late final registerRecognizer = TapGestureRecognizer()..onTap = onRegister;

  void onRegister() => Get.toNamed(AppRoutes.register);

  void onLogin() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    // TODO: authenticate with email and password.
    _goHome();
  }

  // TODO: sign in with the provider before going home.
  void onGoogleLogin() => _goHome();
  void onGithubLogin() => _goHome();

  /// Remembers the session, then clears the auth screens so back can't
  /// return to them and the next app launch opens straight into the chat.
  Future<void> _goHome() async {
    await SessionService.instance.signIn();
    unawaited(Get.offAllNamed(AppRoutes.home));
  }

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
