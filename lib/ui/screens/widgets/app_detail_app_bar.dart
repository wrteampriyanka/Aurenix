import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_plain_background.dart';

/// Top bar of the profile detail screens: reaches up behind the status bar,
/// carries the teal glow, and rounds off its bottom-left and bottom-right
/// corners with a faint outline.
class AppDetailAppBar extends StatelessWidget {
  const AppDetailAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;

  /// Defaults to [Get.back].
  final VoidCallback? onBack;

  /// Shown at the end of the bar, after the title.
  final Widget? action;

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    const shape = BorderRadius.vertical(bottom: Radius.circular(_radius));
    return CustomPaint(
      foregroundPainter: _OpenTopBorderPainter(
        color: color.strokeDark,
        radius: _radius,
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.surfaceDark.withValues(alpha: 0.35),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: topGlowGradient(color.topGlow)),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppBackHeader(
                  title: title,
                  onBack: onBack,
                  action: action,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlines only the bottom edge and its two rounded corners; the line
/// fades out as the corners curve up, so the sides stay open.
class _OpenTopBorderPainter extends CustomPainter {
  const _OpenTopBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 0.5;
    final left = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;
    final path = Path()
      ..moveTo(left, bottom - radius)
      ..arcToPoint(
        Offset(left + radius, bottom),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(right - radius, bottom)
      ..arcToPoint(
        Offset(right, bottom - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0), color],
        ).createShader(Rect.fromLTRB(0, bottom - radius, size.width, bottom)),
    );
  }

  @override
  bool shouldRepaint(_OpenTopBorderPainter old) =>
      old.color != color || old.radius != radius;
}
