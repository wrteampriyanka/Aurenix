import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/savings_controller.dart';

class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Savings')),
      body: const Center(child: CustomText('Savings')),
    );
  }
}
