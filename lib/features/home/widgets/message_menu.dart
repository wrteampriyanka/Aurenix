import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';

/// One line of [showMessageMenu]: an outline icon and a label.
class MessageMenuItem {
  const MessageMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// The card shown on a long press of a sent message: Copy, Select, Edit,
/// Share, the way the big chat apps do it.
///
/// [anchor] is the message bubble in global coordinates; the card opens
/// from the corner nearest it, below the bubble when there is room and
/// above it when there is not.
Future<void> showMessageMenu({
  required BuildContext context,
  required Rect anchor,
  required List<MessageMenuItem> items,
}) async {
  unawaited(HapticFeedback.mediumImpact());
  // The card resolves with the row that was tapped rather than running it
  // itself: an action that opens a sheet off `Get.context` would otherwise
  // build it against this route while the route is still being torn down.
  final picked = await Navigator.of(context, rootNavigator: true)
      .push<MessageMenuItem>(
        PageRouteBuilder<MessageMenuItem>(
          opaque: false,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context)
              .modalBarrierDismissLabel,
          barrierColor: Colors.black.withValues(alpha: 0.4),
          transitionDuration: const Duration(milliseconds: 180),
          reverseTransitionDuration: const Duration(milliseconds: 140),
          pageBuilder: (context, animation, _) =>
              _MessageMenu(anchor: anchor, items: items, animation: animation),
        ),
      );
  picked?.onTap();
}

class _MessageMenu extends StatelessWidget {
  const _MessageMenu({
    required this.anchor,
    required this.items,
    required this.animation,
  });

  final Rect anchor;
  final List<MessageMenuItem> items;
  final Animation<double> animation;

  /// Gap between the bubble and the card.
  static const _gap = 8.0;

  /// Keeps the card off the screen edges.
  static const _margin = 12.0;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    final width = screen.width.clamp(0.0, 420.0) * 0.62;
    // Each row is 52pt plus the card's own padding.
    final height = items.length * 52.0 + 16;

    final below = anchor.bottom + _gap;
    final fitsBelow = below + height <= screen.height - safe.bottom - _margin;
    final top = fitsBelow
        ? below
        : (anchor.top - _gap - height).clamp(safe.top + _margin, below);
    // The card hangs off the bubble's near edge: its right in LTR, its left
    // in RTL, where the user's own bubble sits on the other side.
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final left = (rtl ? anchor.left : anchor.right - width).clamp(
      _margin,
      screen.width - width - _margin,
    );

    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: width,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(curve),
              // Growing out of the bubble's near corner. ScaleTransition
              // takes a resolved Alignment, so mirror it by hand.
              alignment: Alignment(rtl ? -1.0 : 1.0, fitsBelow ? -1.0 : 1.0),
              child: _Card(items: items),
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.items});

  final List<MessageMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: appColors.sidebarBackground,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              InkWell(
                onTap: () => Navigator.of(context).pop(item),
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(item.icon, size: 22, color: appColors.textNatural),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppText(
                          item.label,
                          maxLines: 1,
                          fontSize: AppFontSize.chat,
                          color: appColors.textNatural,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
