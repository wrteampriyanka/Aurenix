import 'package:aurenix/features/presets/models/preset.dart';

/// What the detail screen is opened with: the preset and the tag of the
/// card that was tapped, so the card can fly into the detail header.
class PresetDetailArgs {
  const PresetDetailArgs({required this.preset, required this.heroTag});

  final Preset preset;
  final String heroTag;
}

/// A titled run of presets on the Hand Picked tab.
class PresetGroup {
  const PresetGroup({
    required this.presets,
    required this.layout,
    this.titleKey,
  });

  /// Translation key of the heading; the first group has none.
  final String? titleKey;
  final List<Preset> presets;
  final PresetGroupLayout layout;
}
