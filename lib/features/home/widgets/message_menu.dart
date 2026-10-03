import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

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
}) {
  HapticFeedback.mediumImpact();
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, _) =>
          _MessageMenu(anchor: anchor, items: items, animation: animation),
    ),
  );
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
    final left = (anchor.right - width).clamp(
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
              // Growing out of the bubble's near corner.
              alignment: fitsBelow ? Alignment.topRight : Alignment.bottomRight,
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
      color: context.color.sidebarBackground,
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
                onTap: () {
                  Navigator.of(context).pop();
                  item.onTap();
                },
                child: SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      Icon(
                        item.icon,
                        size: 22,
                        color: context.color.textNatural,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomText(
                          item.label,
                          maxLines: 1,
                          fontSize: 15,
                          color: context.color.textNatural,
                        ),
                      ),
                      const SizedBox(width: 12),
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
