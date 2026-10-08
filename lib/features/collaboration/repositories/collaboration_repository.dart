import 'package:aurenix/features/collaboration/dummy/collaboration_dummy.dart';
import 'package:aurenix/features/collaboration/models/collaborator.dart';

/// Where a project's collaborators and sharing settings come from.
///
/// Returns the bundled dummy data today; swap the bodies for the API calls.
class CollaborationRepository {
  const CollaborationRepository();

  Future<List<Collaborator>> members(String projectId) async => seededMembers();

  /// TODO: send the invite through the API.
  Future<void> invite(String projectId, String email) async {}

  /// TODO: save the new role through the API.
  Future<void> setRole(
    String projectId,
    String memberId,
    CollaboratorRole role,
  ) async {}

  /// TODO: save who may open the project.
  Future<void> setAccess(String projectId, ProjectAccess access) async {}
}
