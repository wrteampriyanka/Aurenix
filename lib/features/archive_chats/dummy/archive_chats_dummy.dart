import 'package:aurenix/features/home/models/chat_summary.dart';

/// Stand-in archived chats until the API can serve them.
///
/// TODO: load the user's archived chats once the API exists.
List<ChatSummary> seededArchivedChats() => <ChatSummary>[
  const ChatSummary(id: 'a1', title: 'Multiverse & Cosmic Power'),
  const ChatSummary(
    id: 'a2',
    title: 'Branched - Incursion of tow universes and their fate',
  ),
  const ChatSummary(id: 'a3', title: 'Astral travel & Subconscious'),
];
