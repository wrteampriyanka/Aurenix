import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Flies a preset card between the list and the detail screen: the card
/// grows from its small size to the big header card, the avatar glides
/// from its place on the small card to its place on the big one, and the
/// rest of the content cross-fades. Both ends must use the same [tag]; the
/// list makes one per card on screen, since a preset can appear in more
/// than one group.
class PresetHero extends StatelessWidget {
  const PresetHero({super.key, required this.tag, required this.child});

  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: (begin, end) => RectTween(begin: begin, end: end),
      flightShuttleBuilder: _shuttle,
      child: child,
    );
  }

  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    // Whichever way we fly, [animation] is 0 at the list and 1 at the
    // detail screen, so the big card's opacity simply follows it.
    final push = direction == HeroFlightDirection.push;
    final small = _FlightEnd.of(push ? fromContext : toContext);
    final big = _FlightEnd.of(push ? toContext : fromContext);
    final color = appColors;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final avatar = Rect.lerp(small.avatar, big.avatar, t);
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.tileBorder),
              ),
            ),
            _FlightContent(
              end: small,
              opacity: const Interval(
                0,
                0.4,
                curve: Curves.easeOut,
              ).transform(1 - t),
            ),
            _FlightContent(
              end: big,
              opacity: const Interval(
                0.3,
                0.9,
                curve: Curves.easeOut,
              ).transform(t),
            ),
            if (avatar != null && small.image != null)
              Positioned.fromRect(
                rect: avatar,
                child: PresetAvatar(image: small.image!, size: avatar.width),
              ),
          ],
        );
      },
    );
  }
}

/// One end of a flight: the hero's child and size on its own screen, and
/// where its avatar sits within it, so the avatar can fly on its own.
class _FlightEnd {
  const _FlightEnd({
    required this.child,
    required this.size,
    required this.avatar,
    required this.image,
  });

  final Widget child;
  final Size? size;
  final Rect? avatar;
  final String? image;

  static _FlightEnd of(BuildContext hero) {
    final box = hero.findRenderObject();
    final size = box is RenderBox && box.hasSize ? box.size : null;
    Rect? avatarRect;
    String? image;
    if (box is RenderBox) {
      final marker = _RenderAvatarMarker.under(box);
      if (marker != null && marker.hasSize) {
        final origin = marker.localToGlobal(Offset.zero, ancestor: box);
        avatarRect = origin & marker.size;
        image = marker.image;
      }
    }
    return _FlightEnd(
      child: (hero.widget as Hero).child,
      size: size,
      avatar: avatarRect,
      image: image,
    );
  }
}

/// Wraps a [PresetAvatar] so a flight can find where it sits.
class _AvatarMarker extends SingleChildRenderObjectWidget {
  const _AvatarMarker({required this.image, required super.child});

  final String image;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderAvatarMarker(image);

  @override
  void updateRenderObject(BuildContext context, _RenderAvatarMarker render) {
    render.image = image;
  }
}

class _RenderAvatarMarker extends RenderProxyBox {
  _RenderAvatarMarker(this.image);

  String image;

  /// The first avatar marker below [root], if any.
  static _RenderAvatarMarker? under(RenderObject root) {
    _RenderAvatarMarker? found;
    void visit(RenderObject child) {
      if (found != null) return;
      if (child is _RenderAvatarMarker) {
        found = child;
        return;
      }
      child.visitChildren(visit);
    }

    root.visitChildren(visit);
    return found;
  }
}

/// One end of the flight, kept at the size it has on its own screen and
/// clipped to the flying rect, so neither card has to re-lay out mid-air.
/// Its own avatar is hidden, since the flight draws one avatar gliding
/// between the two ends.
class _FlightContent extends StatelessWidget {
  const _FlightContent({required this.end, required this.opacity});

  final _FlightEnd end;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final size = end.size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: OverflowBox(
        alignment: AlignmentDirectional.topStart,
        minWidth: size?.width,
        maxWidth: size?.width,
        minHeight: size?.height,
        maxHeight: size?.height,
        child: Opacity(
          opacity: opacity.clamp(0, 1),
          child: _HideAvatars(child: end.child),
        ),
      ),
    );
  }
}

/// Makes every [PresetAvatar] below it draw nothing, keeping its space.
class _HideAvatars extends InheritedWidget {
  const _HideAvatars({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HideAvatars>() != null;

  @override
  bool updateShouldNotify(_HideAvatars oldWidget) => false;
}

/// Rounded card shared by the preset list and the preset detail screen.
/// Tappable when [onTap] is set.
class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.inputFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.tileBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Preset name, bold in the natural text colour: 16px on the list cards,
/// a little larger on the detail screen.
class PresetName extends StatelessWidget {
  const PresetName(this.name, {super.key, this.textAlign, this.fontSize = 16});

  final String name;
  final TextAlign? textAlign;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AppText(
      name,
      maxLines: 1,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      textAlign: textAlign,
      color: appColors.textNatural,
    );
  }
}

/// Preset description, 14px regular in the body colour. Always two lines
/// tall, so cards with short descriptions match the others.
class PresetDescription extends StatelessWidget {
  const PresetDescription(this.description, {super.key, this.textAlign});

  final String description;
  final TextAlign? textAlign;

  static const double _fontSize = 14;

  /// Two lines at [AppText]'s 1.3 line height.
  static const double height = _fontSize * 1.3 * 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppText(
        description,
        maxLines: 2,
        fontSize: _fontSize,
        textAlign: textAlign,
        color: appColors.textBody,
      ),
    );
  }
}

/// The preset's picture: a circle on the list cards, a rounded square
/// ([rounded]) on the detail screen.
class PresetAvatar extends StatelessWidget {
  const PresetAvatar({
    super.key,
    required this.image,
    required this.size,
    this.rounded = false,
  });

  final String image;
  final double size;
  final bool rounded;

  /// Twice the largest avatar drawn (64), in logical pixels.
  static const double _decodeSize = 128;

  @override
  Widget build(BuildContext context) {
    if (_HideAvatars.of(context)) {
      return _AvatarMarker(
        image: image,
        child: SizedBox(width: size, height: size),
      );
    }
    // The source bitmaps are large, so decode them near the drawn size.
    // Every avatar shares one decode, so a card flying into the detail
    // screen never stalls on a second one.
    final cacheWidth = (_decodeSize * MediaQuery.devicePixelRatioOf(context))
        .round();
    final border = Border.all(color: appColors.profileCardBorder);
    return _AvatarMarker(
      image: image,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: rounded
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.25),
                border: border,
              )
            : BoxDecoration(shape: BoxShape.circle, border: border),
        child: Image.asset(image, fit: BoxFit.cover, cacheWidth: cacheWidth),
      ),
    );
  }
}

/// Filled star followed by the preset's average score.
class PresetRating extends StatelessWidget {
  const PresetRating({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(PhosphorIconsFill.star, size: 16, color: color.ratingStar),
        const SizedBox(width: 6),
        AppText(
          rating.toStringAsFixed(1),
          maxLines: 1,
          fontSize: AppFontSize.label,
          color: color.textNatural,
        ),
      ],
    );
  }
}

/// "By - author" with [trailing] (the star rating unless given) at the
/// other end. Spread to the card's edges by default, with a bar between
/// them if [divided]; [centered] groups them in the middle with a bar
/// between, as on the featured cards.
class PresetAuthorRow extends StatelessWidget {
  const PresetAuthorRow({
    super.key,
    required this.preset,
    this.trailing,
    this.centered = false,
    this.divided = false,
  });

  final Preset preset;
  final Widget? trailing;
  final bool centered;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    final author = AppText(
      AppStrings.presetsBy.trParams({'name': preset.author}),
      maxLines: 1,
      fontSize: AppFontSize.label,
      color: color.textNatural,
    );
    final end = trailing ?? PresetRating(rating: preset.rating);
    final bar = Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: color.divider,
    );
    if (divided) {
      // The bar follows the author; the trailing part keeps to the end and
      // shortens before the author does, so long counts never overflow.
      return Row(
        children: [
          Flexible(flex: 2, child: author),
          bar,
          Expanded(
            flex: 3,
            child: Align(alignment: AlignmentDirectional.centerEnd, child: end),
          ),
        ],
      );
    }
    if (!centered) {
      return Row(
        children: [
          Expanded(child: author),
          const SizedBox(width: AppSpacing.sm),
          end,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: author),
        bar,
        end,
      ],
    );
  }
}

/// Outlined "Visit Site" pill with a globe.
class PresetVisitSiteButton extends StatelessWidget {
  const PresetVisitSiteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.sidebarSelected,
      shape: StadiumBorder(side: BorderSide(color: color.tileBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.globeHemisphereWest,
                size: 20,
                color: color.textNatural,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: AppText(
                  AppStrings.presetsVisitSite.tr,
                  maxLines: 1,
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w500,
                  color: color.textNatural,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prompt chips scrolling sideways out to the screen edges.
class PresetQuickStarters extends StatelessWidget {
  const PresetQuickStarters({
    super.key,
    required this.starters,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<String> starters;
  final ValueChanged<String> onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: starters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => Material(
          color: color.inputFill,
          shape: StadiumBorder(side: BorderSide(color: color.tileBorder)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onTap(starters[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: AppText(
                  starters[i],
                  maxLines: 1,
                  fontSize: AppFontSize.label,
                  color: color.textNatural,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small grey heading above a section of the preset screens.
class PresetSectionTitle extends StatelessWidget {
  const PresetSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText(
      title,
      maxLines: 1,
      fontSize: AppFontSize.caption,
      color: appColors.textBody,
    );
  }
}
