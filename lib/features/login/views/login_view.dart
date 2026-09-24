import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Login')),
      body: const Center(child: CustomText('Login')),
    );
  }
}
