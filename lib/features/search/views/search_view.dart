import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/controllers/sidebar_controller.dart';
import '../../home/widgets/app_sidebar.dart';

/// Full-screen sidebar with a live search field that filters the chats.
class SearchView extends GetView<SidebarController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Clears the query on system back too.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.onSearchBack();
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundBase,
        body: const AppSidebar(isSearch: true),
      ),
    );
  }
}
