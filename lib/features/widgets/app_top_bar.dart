import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/ui/screens/widgets/app_composite_icon.dart';
import 'package:aurenix/ui/screens/widgets/custom_text.dart';

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
  final VoidCallback? onMore;

  /// Takes the place of the more button at the end of the pill, e.g. the
  /// avatar of the preset the chat is using.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GlassButton(icon: PhosphorIconsRegular.sidebarSimple, onTap: onMenu),
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
                _PillIcon(
                  icon: PhosphorIconsRegular.chatCircle,
                  overlay: PhosphorIconsRegular.plus,
                  onTap: onNewChat,
                ),
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
                  _PillIcon(
                    icon: PhosphorIconsRegular.dotsThree,
                    onTap: onMore,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.iconSize = 22,
  });

  final IconData icon;
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
            child: Icon(icon, size: iconSize, color: context.color.textNatural),
          ),
        ),
      ),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon, required this.onTap, this.overlay});

  final IconData icon;

  /// Drawn small over the centre of [icon], see [AppCompositeIcon].
  final IconData? overlay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 44,
        height: 46,
        child: overlay == null
            ? Icon(icon, size: 22, color: context.color.textNatural)
            : AppCompositeIcon(
                icon: icon,
                overlay: overlay!,
                color: context.color.textNatural,
              ),
      ),
    );
  }
}
