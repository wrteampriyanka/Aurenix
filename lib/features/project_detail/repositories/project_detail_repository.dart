import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/project_detail/dummy/project_detail_dummy.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/project_files_sheet.dart';

/// Where one project's chats and files come from.
///
/// Returns the bundled dummy data today; swap the bodies for the API calls.
class ProjectDetailRepository {
  const ProjectDetailRepository();

  Future<List<ChatSummary>> chats(String projectId) async =>
      seededProjectChats();

  Future<List<ProjectFile>> files(String projectId) async =>
      seededProjectFiles();

  /// TODO: upload the file and return what the API stored.
  Future<void> addFile(String projectId, ProjectFile file) async {}

  /// TODO: delete the file through the API.
  Future<void> removeFile(String projectId, String fileId) async {}
}
