import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MemoriesController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  final referenceSavedMemories = true.obs;
  final referenceChatHistory = true.obs;

  // TODO: load the user's saved memories once the API exists.
  final memories = <String>[
    'Saturn has a mean radius of approximately 58,232 kilometers, making it '
        'about 9.14 times larger than Earth in radius.',
    'You Said that you are vegetarian',
    'You Said that you can also make 2D and 3D Animations in Rive & Blender',
    'You Said that your UI Kit just got rejected without any reason',
  ].obs;

  /// Memories that contain the search query.
  List<String> get filteredMemories {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return memories;
    return memories.where((m) => m.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
  }

  void onReferenceSavedMemories(bool value) =>
      referenceSavedMemories.value = value;

  void onReferenceChatHistory(bool value) => referenceChatHistory.value = value;

  // TODO: sync with the API once it exists.
  void onRemoveAll() => memories.clear();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
