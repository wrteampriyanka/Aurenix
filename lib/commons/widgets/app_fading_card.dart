import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/theme/app_spacing.dart';

/// Where a card's outline fades out.
enum CardFade {
  /// Strong at the top left, gone by the bottom right corner.
  diagonal,

  /// The whole left edge stays solid; the outline fades out towards the
  /// right, so nothing is missing down the left of the card.
  rightward,

  /// The top edge stays solid; the outline fades out towards the bottom, so
  /// both bottom corners go at once and nothing is missing on one side only.
  downward,

  /// No fade: the whole outline is drawn at full strength, so the card reads
  /// as a closed box with its bottom edge intact.
  none,
}

/// Frosted card whose fill and outline fade out towards the bottom right,
/// used for the profile card and the upgrade plan cards.
class AppFadingCard extends StatelessWidget {
  const AppFadingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = 20,
    this.fill,
    this.fade = CardFade.diagonal,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Which way the outline fades out.
  final CardFade fade;

  /// Fill the card fades out from. Transparent leaves the page background
  /// showing through, with only the fading outline drawn.
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final fill = this.fill ?? appColors.profileCardFill;
    return CustomPaint(
      foregroundPainter: _FadingBorderPainter(
        color: appColors.profileCardBorder,
        radius: radius,
        fade: fade,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          // A closed card keeps an even fill; a fading one lets the page
          // show through towards the bottom.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: fade == CardFade.none
                ? [fill, fill]
                : [fill, fill.withValues(alpha: 0)],
            stops: const [0.0, 0.85],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A 1px outline that fades out from the top left to the bottom right.
class _FadingBorderPainter extends CustomPainter {
  const _FadingBorderPainter({
    required this.color,
    required this.radius,
    required this.fade,
  });

  final Color color;
  final double radius;
  final CardFade fade;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;
    // Gradient axis runs along (h, w) rather than the diagonal (w, h), so the
    // top-right and bottom-left corners sit at the same point (0.5) whatever
    // the card's aspect ratio, and only the bottom-right corner reaches 1.
    final scale = 2 * w * h / (w * w + h * h);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = switch (fade) {
        CardFade.diagonal => ui.Gradient.linear(
          Offset.zero,
          Offset(h * scale, w * scale),
          [color, color, color.withValues(alpha: 0)],
          const [0.0, 0.4, 0.9],
        ),
        // Straight across, so both left corners sit at 0 and the edge
        // between them is drawn at full strength.
        CardFade.rightward => ui.Gradient.linear(
          Offset.zero,
          Offset(w, 0),
          [color, color, color.withValues(alpha: 0)],
          const [0.0, 0.45, 1.0],
        ),
        // Straight down, so both top corners sit at 0 and the outline is
        // gone by the bottom on the left and the right alike.
        CardFade.downward => ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [color, color, color.withValues(alpha: 0)],
          const [0.0, 0.35, 0.95],
        ),
        // Every edge at full strength: a closed outline, no fade.
        CardFade.none => ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [color, color],
          const [0.0, 1.0],
        ),
      };
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FadingBorderPainter old) =>
      old.color != color || old.radius != radius || old.fade != fade;
}
