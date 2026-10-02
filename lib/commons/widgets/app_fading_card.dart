import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Frosted card whose fill and outline fade out towards the bottom right,
/// used for the profile card and the upgrade plan cards.
class AppFadingCard extends StatelessWidget {
  const AppFadingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fill = context.color.profileCardFill;
    return CustomPaint(
      foregroundPainter: _FadingBorderPainter(
        color: context.color.profileCardBorder,
        radius: radius,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill, fill.withValues(alpha: 0)],
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
  const _FadingBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

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
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(h * scale, w * scale),
        [color, color, color.withValues(alpha: 0)],
        const [0.0, 0.4, 0.9],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FadingBorderPainter old) =>
      old.color != color || old.radius != radius;
}
