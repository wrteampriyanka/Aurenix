import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/ui/screens/widgets/custom_text.dart';
import 'package:aurenix/ui/screens/categories/controllers/categories_controller.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Categories')),
      body: const Center(child: CustomText('Categories')),
    );
  }
}
