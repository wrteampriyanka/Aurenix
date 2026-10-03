import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/app_plain_background.dart';
import 'package:aurenix/features/widgets/app_search_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';
import 'package:aurenix/features/presets/widgets/preset_widgets.dart';

/// Called with the tapped preset and the hero tag of its card.
typedef PresetTap = void Function(Preset preset, String heroTag);

/// Catalogue of ready-made AI assistants, opened from "Presets" in the
/// sidebar. Search and the filter chips stay pinned above the list.
///
/// The body has no side padding of its own, so the featured row can scroll
/// out to the screen edges; everything else adds [_side] itself.
class PresetsScreen extends GetView<PresetsController> {
  const PresetsScreen({super.key});

  static const double _side = 16;
  static const _sidePadding = EdgeInsets.symmetric(horizontal: _side);
  static const _gap = SizedBox(height: 10);

  @override
  Widget build(BuildContext context) {
    controller.route = ModalRoute.of(context);
    return AppDetailPage(
      title: 'presets_title'.tr,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(_side, 8, _side, 12),
            child: AppSearchField(
              controller: controller.searchController,
              hintText: 'presets_search_hint'.tr,
            ),
          ),
          _FilterChips(controller: controller),
          const SizedBox(height: 8),
        ],
      ),
      child: Obx(() {
        if (controller.isFiltering) {
          return _Results(controller: controller);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, group) in PresetsController.groups.indexed)
              _GroupView(
                group: group,
                heroPrefix: 'group$i',
                onPreset: controller.onPreset,
              ),
          ],
        );
      }),
    );
  }
}

/// Horizontally scrolling row of filter chips; the selected one is lit.
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});

  final PresetsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = controller.filter.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: PresetsScreen._sidePadding,
          itemCount: PresetFilter.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final filter = PresetFilter.values[i];
            return _FilterChip(
              label: filter.labelKey.tr,
              selected: filter == selected,
              onTap: () => controller.onFilter(filter),
            );
          },
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Material(
      color: selected ? color.sidebarSelected : color.inputFill,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? color.buttonBorder : color.tileBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: CustomText(
              label,
              maxLines: 1,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color.textNatural,
            ),
          ),
        ),
      ),
    );
  }
}

/// Flat list shown while searching or when a chip other than Hand Picked
/// is selected.
class _Results extends StatelessWidget {
  const _Results({required this.controller});

  final PresetsController controller;

  @override
  Widget build(BuildContext context) {
    final results = controller.results;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: CustomText(
          'presets_empty'.tr,
          fontSize: 14,
          textAlign: TextAlign.center,
          color: context.color.textBody,
        ),
      );
    }
    return Padding(
      padding: PresetsScreen._sidePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final preset in results) ...[
            _PresetTile(
              preset: preset,
              heroTag: 'results-${preset.id}',
              onTap: controller.onPreset,
            ),
            PresetsScreen._gap,
          ],
        ],
      ),
    );
  }
}

/// A heading (if any) followed by its presets in the group's layout.
class _GroupView extends StatelessWidget {
  const _GroupView({
    required this.group,
    required this.heroPrefix,
    required this.onPreset,
  });

  final PresetGroup group;

  /// Makes this group's hero tags unique, since a preset can appear in
  /// more than one group.
  final String heroPrefix;
  final PresetTap onPreset;

  @override
  Widget build(BuildContext context) {
    final presets = group.presets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.titleKey case final titleKey?)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PresetsScreen._side,
              10,
              PresetsScreen._side,
              10,
            ),
            child: PresetSectionTitle(titleKey.tr),
          ),
        switch (group.layout) {
          PresetGroupLayout.featured => _FeaturedRow(
            presets: presets,
            heroPrefix: heroPrefix,
            onPreset: onPreset,
          ),
          PresetGroupLayout.tile || PresetGroupLayout.ranked => Padding(
            padding: PresetsScreen._sidePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < presets.length; i++) ...[
                  _PresetTile(
                    preset: presets[i],
                    heroTag: '$heroPrefix-${presets[i].id}',
                    rank: group.layout == PresetGroupLayout.ranked
                        ? i + 1
                        : null,
                    onTap: onPreset,
                  ),
                  PresetsScreen._gap,
                ],
              ],
            ),
          ),
        },
      ],
    );
  }
}

/// Featured cards side by side, scrolling sideways out to the screen edges
/// with the next card peeking in from the right.
class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({
    required this.presets,
    required this.heroPrefix,
    required this.onPreset,
  });

  final List<Preset> presets;
  final String heroPrefix;
  final PresetTap onPreset;

  static const double _height = 212;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.82;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: _height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: PresetsScreen._sidePadding,
          itemCount: presets.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (_, i) => SizedBox(
            width: width,
            child: _FeaturedPresetCard(
              preset: presets[i],
              heroTag: '$heroPrefix-${presets[i].id}',
              onTap: onPreset,
            ),
          ),
        ),
      ),
    );
  }
}

/// Round avatar on the left, name and description on the right, and the
/// author and rating under a divider that spans the card. The description
/// always takes two lines, so every tile is the same height. With [rank]
/// set, a numbered badge leads the top row, centred on the avatar.
class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.heroTag,
    required this.onTap,
    this.rank,
  });

  final Preset preset;
  final String heroTag;
  final PresetTap onTap;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return PresetHero(
      tag: heroTag,
      child: PresetCard(
        onTap: () => onTap(preset, heroTag),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (rank case final rank?) ...[
                  _RankBadge(rank: rank),
                  const SizedBox(width: 12),
                ],
                PresetAvatar(image: preset.image, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PresetName(preset.name),
                      const SizedBox(height: 4),
                      PresetDescription(preset.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: color.profileCardDivider),
            const SizedBox(height: 12),
            PresetAuthorRow(preset: preset),
          ],
        ),
      ),
    );
  }
}

/// Large card with the round avatar, name and description centred.
class _FeaturedPresetCard extends StatelessWidget {
  const _FeaturedPresetCard({
    required this.preset,
    required this.heroTag,
    required this.onTap,
  });

  final Preset preset;
  final String heroTag;
  final PresetTap onTap;

  @override
  Widget build(BuildContext context) {
    return PresetHero(
      tag: heroTag,
      child: PresetCard(
        onTap: () => onTap(preset, heroTag),
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: PresetAvatar(image: preset.image, size: 64)),
            const SizedBox(height: 14),
            PresetName(preset.name, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PresetDescription(
                preset.description,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            PresetAuthorRow(preset: preset, centered: true),
          ],
        ),
      ),
    );
  }
}

/// Round grey badge with the preset's place in a ranked list.
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.rankBadge,
        border: Border.all(color: color.rankBadgeBorder),
      ),
      child: CustomText(
        '$rank',
        maxLines: 1,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color.textNatural,
      ),
    );
  }
}
