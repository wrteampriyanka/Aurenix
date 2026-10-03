import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/features/budget/controllers/budget_controller.dart';

class BudgetScreen extends GetView<BudgetController> {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Budget')),
      body: const Center(child: CustomText('Budget')),
    );
  }
}
