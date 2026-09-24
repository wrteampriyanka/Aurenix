import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Profile')),
      body: const Center(child: CustomText('Profile')),
    );
  }
}
