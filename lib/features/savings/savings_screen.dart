import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/ui/screens/widgets/custom_text.dart';
import 'package:aurenix/ui/screens/savings/controllers/savings_controller.dart';

class SavingsScreen extends GetView<SavingsController> {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Savings')),
      body: const Center(child: CustomText('Savings')),
    );
  }
}
