import 'package:get/get.dart';

import '../controllers/archive_chats_controller.dart';

class ArchiveChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchiveChatsController>(() => ArchiveChatsController());
  }
}
