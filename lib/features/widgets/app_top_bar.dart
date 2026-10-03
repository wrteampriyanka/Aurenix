import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/widgets/app_svg_icon.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// Frosted top bar shared by home and profile: sidebar button, model name
/// with a caret, and a pill holding the new chat and more buttons.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.onMenu,
    this.onModelTap,
    this.onNewChat,
    this.onMore,
    this.trailing,
  });

  final VoidCallback onMenu;
  final VoidCallback? onModelTap;
  final VoidCallback? onNewChat;

  /// Opens the chat menu over the "..." button; the rect is the button in
  /// global coordinates, so the card can grow out of its corner.
  final ValueChanged<Rect>? onMore;

  /// Takes the place of the more button at the end of the pill, e.g. the
  /// avatar of the preset the chat is using.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GlassButton(asset: AppAssets.menuIcon, onTap: onMenu),
          Expanded(
            child: GestureDetector(
              onTap: onModelTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomText(
                      'home_model_name'.tr,
                      maxLines: 1,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.color.textNatural,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 18,
                    color: context.color.textNatural,
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: glassDecoration(context, BoxShape.rectangle),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The drawn icon already carries its plus, so no overlay.
                _PillIcon(asset: AppAssets.addChatIcon, onTap: onNewChat),
                SizedBox(
                  height: 24,
                  child: VerticalDivider(
                    width: 1,
                    color: context.color.tileBorder,
                  ),
                ),
                if (trailing case final trailing?)
                  SizedBox(
                    width: 44,
                    height: 46,
                    child: Center(child: trailing),
                  )
                else
                  Builder(
                    builder: (context) => _PillIcon(
                      icon: PhosphorIconsRegular.dotsThree,
                      onTap: onMore == null
                          ? null
                          : () => _reportMore(context, onMore!),
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

/// Hands [onMore] the "..." button's place on screen, so the menu it opens
/// can line up with it.
void _reportMore(BuildContext context, ValueChanged<Rect> onMore) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return;
  onMore(box.localToGlobal(Offset.zero) & box.size);
}

/// Frosted decoration shared by the top bar buttons.
BoxDecoration glassDecoration(BuildContext context, BoxShape shape) =>
    BoxDecoration(
      shape: shape,
      borderRadius: shape == BoxShape.rectangle
          ? BorderRadius.circular(24)
          : null,
      color: context.color.tileFillHighlight,
      border: Border.all(color: context.color.tileBorder),
    );

/// Round frosted icon button.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    this.icon,
    this.asset,
    required this.onTap,
    this.size = 48,
    this.iconSize = 22,
  }) : assert(icon != null || asset != null, 'give an icon or an asset');

  /// A font icon, or null when [asset] is used instead.
  final IconData? icon;

  /// An SVG from `assets/images`, tinted like the font icon it replaces.
  final String? asset;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: glassDecoration(context, BoxShape.circle),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: asset != null
                  ? AppSvgIcon(
                      asset!,
                      size: iconSize,
                      color: context.color.textNatural,
                    )
                  : Icon(
                      icon,
                      size: iconSize,
                      color: context.color.textNatural,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({this.icon, this.asset, required this.onTap});

  /// A font icon, or null when [asset] is used instead.
  final IconData? icon;

  /// An SVG from `assets/images`, tinted like a font icon.
  final String? asset;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 44,
        height: 46,
        child: asset != null
            ? Center(
                child: AppSvgIcon(
                  asset!,
                  size: 22,
                  color: context.color.textNatural,
                ),
              )
            : Icon(icon, size: 22, color: context.color.textNatural),
      ),
    );
  }
}
