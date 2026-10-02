import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../commons/widgets/custom_text.dart';
import '../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomText('Categories')),
      body: const Center(child: CustomText('Categories')),
    );
  }
}
