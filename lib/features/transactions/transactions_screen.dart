import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/features/transactions/controllers/transactions_controller.dart';

class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Transactions')),
      body: const Center(child: CustomText('Transactions')),
    );
  }
}
