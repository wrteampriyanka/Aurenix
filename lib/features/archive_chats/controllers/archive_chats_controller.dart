import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/home/controllers/sidebar_controller.dart';

/// Actions offered from an archived chat's more menu.
enum ArchivedChatAction { unarchive, delete }

class ArchiveChatsController extends GetxController {
  final searchController = TextEditingController();
  final query = ''.obs;

  // TODO: load the user's archived chats once the API exists.
  final chats = <ChatSummary>[
    const ChatSummary(id: 'a1', title: 'Multiverse & Cosmic Power'),
    const ChatSummary(
      id: 'a2',
      title: 'Branched - Incursion of tow universes and their fate',
    ),
    const ChatSummary(id: 'a3', title: 'Astral travel & Subconscious'),
  ].obs;

  /// Archived chats whose title contains the search query.
  List<ChatSummary> get filteredChats {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return chats;
    return chats.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => query.value = searchController.text);
  }

  // TODO: open the chat once chat history can be loaded by id.
  void onChat(ChatSummary chat) {}

  // TODO: sync with the API; for now both just drop it from this list.
  void onAction(ChatSummary chat, ArchivedChatAction action) {
    chats.removeWhere((c) => c.id == chat.id);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
