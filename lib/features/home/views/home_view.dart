import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Home')),
      body: const Center(child: CustomText('Home')),
    );
  }
}
