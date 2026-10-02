import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/budget_controller.dart';

class BudgetView extends GetView<BudgetController> {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Budget')),
      body: const Center(child: CustomText('Budget')),
    );
  }
}
