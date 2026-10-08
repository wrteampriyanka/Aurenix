import 'package:aurenix/features/memories/dummy/memories_dummy.dart';

/// Where the user's saved memories come from.
///
/// Returns the bundled dummy data today; swap the body for the API call.
class MemoriesRepository {
  const MemoriesRepository();

  Future<List<String>> memories() async => seededMemories();

  /// TODO: tell the API the memory was forgotten.
  Future<void> forget(String memory) async {}

  /// TODO: tell the API every memory was forgotten.
  Future<void> forgetAll() async {}
}
