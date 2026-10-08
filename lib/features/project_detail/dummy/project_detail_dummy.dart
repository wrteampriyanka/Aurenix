import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/project_files_sheet.dart';

/// Stand-in project content until the API can serve it.
///
/// TODO: delete this file once a project's chats and files come from the
/// backend.
List<ChatSummary> seededProjectChats() => <ChatSummary>[
  ChatSummary(
    id: 'pc1',
    title: 'Multiverse & Cosmic Power',
    authorInitials: 'MS',
    authorColor: appColors.avatarSwatch[0],
  ),
  ChatSummary(
    id: 'pc2',
    title: 'Branched - Incursion of tow universes',
    authorInitials: 'AL',
    authorColor: appColors.avatarSwatch[1],
  ),
  ChatSummary(
    id: 'pc3',
    title: 'Astral travel & Subconscious',
    authorInitials: 'RM',
    authorColor: appColors.avatarSwatch[2],
  ),
];

List<ProjectFile> seededProjectFiles() => <ProjectFile>[
  const ProjectFile(id: 'pf1', name: 'Universe Study Doc 3', bytes: 23 << 20),
  const ProjectFile(
    id: 'pf2',
    name: 'Warm Hole - Research Paper',
    bytes: 103 << 20,
  ),
  const ProjectFile(id: 'pf3', name: 'Paper Universe Theory', bytes: 11 << 20),
  const ProjectFile(
    id: 'pf4',
    name: 'Project Question Entanglement',
    bytes: 493 << 20,
  ),
];
