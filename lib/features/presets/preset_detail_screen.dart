import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_plain_background.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/presets/controllers/preset_detail_controller.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';
import 'package:aurenix/features/presets/widgets/preset_widgets.dart';

/// Everything about one preset: its card, ratings, capabilities and quick
/// starter prompts, with "Start Chat" pinned to the bottom.
///
/// The body has no side padding of its own, so the quick starters can
/// scroll out to the screen edges; the other sections add [_side].
class PresetDetailScreen extends GetView<PresetDetailController> {
  const PresetDetailScreen({super.key});

  static const double _side = 16;
  static const _sidePadding = EdgeInsets.symmetric(horizontal: _side);

  @override
  Widget build(BuildContext context) {
    final preset = controller.preset;
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppPlainBackground(
        glow: context.color.backgroundGlow,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Reveal(index: 0, child: AppBackHeader()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: _sidePadding,
                      child: PresetHero(
                        tag: controller.heroTag,
                        child: _HeaderCard(
                          preset: preset,
                          onVisitSite: controller.onVisitSite,
                        ),
                      ),
                    ),
                    _Reveal(
                      index: 1,
                      child: _Section(
                        title: 'presets_ratings_reviews'.tr,
                        child: _RatingsCard(preset: preset),
                      ),
                    ),
                    _Reveal(
                      index: 2,
                      child: _Section(
                        title: 'presets_capabilities'.tr,
                        child: _CapabilitiesCard(preset.capabilities),
                      ),
                    ),
                    _Reveal(
                      index: 3,
                      child: _Section(
                        title: 'presets_quick_starters'.tr,
                        padded: false,
                        child: PresetQuickStarters(
                          starters: preset.quickStarters,
                          onTap: controller.onStartChat,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _Reveal(
                index: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(_side, 8, _side, 16),
                  child: AppButton(
                    label: 'presets_start_chat'.tr,
                    fontSize: 16,
                    height: 52,
                    onPressed: controller.onStartChat,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades its child in and nudges it up as the page opens, a little later
/// for each [index], so the sections cascade in under the landing card.
/// Plays in reverse on the way back.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  static final _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return child;
    final start = (0.2 + index * 0.1).clamp(0.0, 0.7);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      reverseCurve: Interval(0, 1 - start, curve: Curves.easeIn),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: _slide.animate(curved), child: child),
    );
  }
}

/// Grey heading with its content under it. [padded] adds the side padding
/// to the content; turn it off for content that scrolls to the edges.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.padded = true,
  });

  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PresetDetailScreen._side,
            18,
            PresetDetailScreen._side,
            10,
          ),
          child: PresetSectionTitle(title),
        ),
        if (padded)
          Padding(padding: PresetDetailScreen._sidePadding, child: child)
        else
          child,
      ],
    );
  }
}

/// Category rank, avatar with "Visit Site", name and description, and the
/// author with the conversation count under a divider.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.preset, required this.onVisitSite});

  final Preset preset;
  final VoidCallback onVisitSite;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.cardShadow,
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: PresetCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category strip like the app bar: a blue tint on the left
            // fading into the card towards the right, with a line under it
            // spanning the card.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    color.cardStripTint,
                    color.cardStripTint.withValues(alpha: 0),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: color.profileCardDivider),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: CustomText(
                  'presets_category_rank'.trParams({
                    'rank': '${preset.categoryRank}',
                    'category': preset.category,
                  }),
                  maxLines: 1,
                  fontSize: 14,
                  color: color.textNatural,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PresetAvatar(image: preset.image, size: 68),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: PresetVisitSiteButton(onTap: onVisitSite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PresetName(preset.name, fontSize: 18),
                  const SizedBox(height: 6),
                  PresetDescription(preset.description),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: color.profileCardDivider),
                  const SizedBox(height: 14),
                  PresetAuthorRow(
                    preset: preset,
                    divided: true,
                    trailing: _Conversations(count: preset.conversations),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circled plus followed by "+65K Conversations".
class _Conversations extends StatelessWidget {
  const _Conversations({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          PhosphorIconsRegular.plusCircle,
          size: 18,
          color: color.textNatural,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: CustomText(
            'presets_conversations'.trParams({'count': count}),
            maxLines: 1,
            fontSize: 14,
            color: color.textNatural,
          ),
        ),
      ],
    );
  }
}

/// The average score and review count on a small card, with a bar for
/// each star level beside it.
class _RatingsCard extends StatelessWidget {
  const _RatingsCard({required this.preset});

  final Preset preset;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PresetCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsFill.star,
                      size: 30,
                      color: color.ratingStar,
                    ),
                    const SizedBox(width: 10),
                    CustomText(
                      preset.rating.toStringAsFixed(1),
                      maxLines: 1,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: color.textNatural,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomText(
                  'presets_reviews_count'.trParams({
                    'count': '${preset.reviews}',
                  }),
                  maxLines: 1,
                  fontSize: 12,
                  color: color.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < preset.ratingBreakdown.length; i++)
                  _RatingBar(
                    stars: preset.ratingBreakdown.length - i,
                    share: preset.ratingBreakdown[i],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Star count on the left and a bar filled to [share].
class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.stars, required this.share});

  final int stars;
  final double share;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: CustomText(
            '$stars',
            maxLines: 1,
            fontSize: 13,
            textAlign: TextAlign.center,
            color: color.textNatural,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: share.clamp(0, 1),
              minHeight: 6,
              backgroundColor: color.ratingBarTrack,
              color: color.ratingBarFill,
            ),
          ),
        ),
      ],
    );
  }
}

/// One ticked line per capability.
class _CapabilitiesCard extends StatelessWidget {
  const _CapabilitiesCard(this.capabilities);

  final List<String> capabilities;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return PresetCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          for (final capability in capabilities)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.check,
                    size: 18,
                    color: color.textNatural,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomText(
                      capability,
                      maxLines: 1,
                      fontSize: 14,
                      color: color.textNatural,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
