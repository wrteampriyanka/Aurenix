import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:aurenix/features/memories/repositories/memories_repository.dart';

class MemoriesController extends GetxController {
  final _repository = const MemoriesRepository();

  final searchController = TextEditingController();
  final query = ''.obs;

  final referenceSavedMemories = true.obs;
  final referenceChatHistory = true.obs;

  final memories = <String>[].obs;

  /// Memories that contain the search query.
  List<String> get filteredMemories {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return memories;
    return memories.where((m) => m.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _load();
    searchController.addListener(() => query.value = searchController.text);
  }

  void onReferenceSavedMemories(bool value) =>
      referenceSavedMemories.value = value;

  void onReferenceChatHistory(bool value) => referenceChatHistory.value = value;

  // TODO: sync with the API once it exists.
  void onRemoveAll() => memories.clear();

  Future<void> _load() async {
    memories.value = await _repository.memories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
