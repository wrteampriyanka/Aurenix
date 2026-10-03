import 'package:get/get.dart';

import 'package:aurenix/ui/screens/archive_chats/controllers/archive_chats_controller.dart';

class ArchiveChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchiveChatsController>(() => ArchiveChatsController());
  }
}
