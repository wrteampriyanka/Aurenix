import 'package:aurenix/features/home/dummy/sidebar_dummy.dart' as dummy;
import 'package:aurenix/features/home/models/chat_message.dart';
import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/home/models/project.dart';

/// Where the sidebar's projects, chats and transcripts come from.
///
/// Every method returns the bundled dummy data today. When the API lands,
/// only the bodies here change — [SidebarController] already awaits them.
class SidebarRepository {
  const SidebarRepository();

  Future<List<Project>> projects() async => dummy.seededProjects();

  Future<List<ChatSummary>> chats() async => dummy.seededChats();

  /// The stored messages of every seeded chat, keyed by chat id.
  Future<Map<String, List<ChatMessage>>> transcripts() async {
    final byId = <String, List<ChatMessage>>{};
    for (final entry in dummy.demoTranscripts.entries) {
      byId[entry.key] = [
        for (final (i, text) in entry.value.indexed)
          ChatMessage.history(isUser: i.isEven, text: text),
      ];
    }
    // The project screen lists the same conversations under its own ids.
    for (final entry in dummy.demoAliases.entries) {
      byId[entry.key] = byId[entry.value]!;
    }
    return byId;
  }
}
