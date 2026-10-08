import 'package:aurenix/features/archive_chats/dummy/archive_chats_dummy.dart';
import 'package:aurenix/features/home/models/chat_summary.dart';

/// Where the user's archived chats come from.
///
/// Returns the bundled dummy data today; swap the body for the API call.
class ArchiveChatsRepository {
  const ArchiveChatsRepository();

  Future<List<ChatSummary>> archivedChats() async => seededArchivedChats();

  /// TODO: tell the API the chat was restored.
  Future<void> unarchive(String id) async {}

  /// TODO: tell the API the chat was deleted.
  Future<void> delete(String id) async {}
}
