import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/features/presets/models/preset_group.dart';
import 'package:aurenix/features/presets/repositories/presets_repository.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Opens [preset]'s site in the browser, with a snackbar if that fails.
Future<void> openPresetSite(Preset preset) async {
  final opened = await launchUrl(
    Uri.parse(preset.siteUrl),
    mode: LaunchMode.externalApplication,
  );
  if (!opened) AppSnackbar.error(AppStrings.chatOpenFailed.tr);
}

/// Search, filter chips and the preset lists on the Presets screen.
class PresetsController extends GetxController {
  /// The list's route, so Start Chat on a preset can drop it from the
  /// stack and close straight onto the chat.
  Route<dynamic>? route;

  final searchController = TextEditingController();

  /// Trimmed text of the search field.
  final query = ''.obs;

  final filter = PresetFilter.handPicked.obs;

  final _repository = const PresetsRepository();

  /// Every preset, in catalogue order, for search and the filter chips.
  final presets = <Preset>[].obs;

  /// The curated layout of the Hand Picked tab.
  final groups = <PresetGroup>[].obs;

  /// True while a search or a chip other than Hand Picked narrows the list,
  /// in which case [results] replaces [groups].
  bool get isFiltering =>
      query.value.isNotEmpty || filter.value != PresetFilter.handPicked;

  /// Presets matching the search text and the selected chip.
  List<Preset> get results {
    final q = query.value;
    final f = filter.value;
    return [
      for (final preset in presets)
        if ((f == PresetFilter.handPicked || preset.filters.contains(f)) &&
            (q.isEmpty || preset.matches(q)))
          preset,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _load();
  }

  Future<void> _load() async {
    presets.value = await _repository.presets();
    groups.value = await _repository.groups();
  }

  void _onSearchChanged() => query.value = searchController.text.trim();

  void onFilter(PresetFilter value) => filter.value = value;

  /// Opens the detail screen; [heroTag] names the card that was tapped.
  void onPreset(Preset preset, String heroTag) => Get.toNamed(
    AppRoutes.presetDetail,
    arguments: PresetDetailArgs(preset: preset, heroTag: heroTag),
  );

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
