import 'package:aurenix/features/presets/dummy/presets_dummy.dart' as dummy;
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/features/presets/models/preset_group.dart';

/// Where the preset catalogue comes from.
///
/// Returns the bundled dummy data today; swap the bodies for the API calls.
class PresetsRepository {
  const PresetsRepository();

  /// Every preset, in catalogue order, for search and the filter chips.
  Future<List<Preset>> presets() async => dummy.presets;

  /// The curated layout of the Hand Picked tab.
  Future<List<PresetGroup>> groups() async => dummy.groups;
}
