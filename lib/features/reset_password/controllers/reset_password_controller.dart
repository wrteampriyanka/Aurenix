import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/utils/validators.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  /// Email whose password is being reset, passed as the route argument.
  /// Null when the route was opened without one; `as String?` would still
  /// throw on an argument of any other type.
  final String? email = Get.arguments is String
      ? Get.arguments as String
      : null;

  String? validateConfirm(String? value) =>
      Validators.confirmPassword(value, passwordController.text);

  void onSubmit() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    // TODO: save the new password for [email].
    // Pops OTP and this screen, back to the login screen.
    Get.until((route) => route.settings.name == AppRoutes.login);
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
