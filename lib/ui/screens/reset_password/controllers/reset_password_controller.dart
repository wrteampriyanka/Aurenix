import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../utils/validators.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  /// Email whose password is being reset, passed as the route argument.
  final String? email = Get.arguments as String?;

  final isPasswordHidden = true.obs;
  final isConfirmHidden = true.obs;

  void togglePasswordVisibility() => isPasswordHidden.toggle();
  void toggleConfirmVisibility() => isConfirmHidden.toggle();

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
