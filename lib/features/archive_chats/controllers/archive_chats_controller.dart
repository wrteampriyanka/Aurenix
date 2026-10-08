import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/archive_chats/repositories/archive_chats_repository.dart';

/// Actions offered from an archived chat's more menu.
enum ArchivedChatAction { unarchive, delete }

class ArchiveChatsController extends GetxController {
  final _repository = const ArchiveChatsRepository();

  final searchController = TextEditingController();
  final query = ''.obs;

  final chats = <ChatSummary>[].obs;

  /// Archived chats whose title contains the search query.
  List<ChatSummary> get filteredChats {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _load();
    searchController.addListener(() => query.value = searchController.text);
  }

  // TODO: open the chat once chat history can be loaded by id.
  void onChat(ChatSummary chat) {}

  // TODO: sync with the API; for now both just drop it from this list.
  void onAction(ChatSummary chat, ArchivedChatAction action) {
    chats.removeWhere((c) => c.id == chat.id);
  }

  Future<void> _load() async {
    chats.value = await _repository.archivedChats();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
