import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/elapsed_time_mixin.dart';

/// k_glowing_blurs.dart
///
/// Pure canvas-based glowing blur background layer.
/// - No images
/// - Fixed positions (configurable per screen)
/// - Soft in–out glow animation
/// - Fully optional & reusable
///
/// Positions are defined via [GlowConfig] so every screen
/// can supply its own layout without touching painter logic.
///
/// Animation is driven entirely via [CustomPainter.repaint] so only
/// [paint] runs per frame — the widget tree is never rebuilt during animation.

@immutable
class GlowConfig {
  const GlowConfig({
    required this.position,
    required this.radiusFactor,
    required this.color,
    this.baseOpacity = 0.6,
    this.pulseStrength = 0.15,
    this.pulseSpeed = 1.0,
  });

  /// Position as a percentage of screen size (0 → 1)
  final Offset position;

  /// Radius as a percentage of screen width
  final double radiusFactor;

  final Color color;
  final double baseOpacity;
  final double pulseStrength;
  final double pulseSpeed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlowConfig &&
        other.position == position &&
        other.radiusFactor == radiusFactor &&
        other.color == color &&
        other.baseOpacity == baseOpacity &&
        other.pulseStrength == pulseStrength &&
        other.pulseSpeed == pulseSpeed;
  }

  @override
  int get hashCode => Object.hash(
    position,
    radiusFactor,
    color,
    baseOpacity,
    pulseStrength,
    pulseSpeed,
  );
}

class KGlowingBlurs extends StatefulWidget {
  const KGlowingBlurs({
    required this.glows,
    super.key,
    this.intensity = 1.0,
    this.animate = true,
  });

  final List<GlowConfig> glows;
  final double intensity;
  final bool animate;

  @override
  State<KGlowingBlurs> createState() => _KGlowingBlursState();
}

class _KGlowingBlursState extends State<KGlowingBlurs>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _GlowPainter(
            glows: widget.glows,
            intensity: widget.intensity,
            time: time,
            animate: widget.animate,
          ),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.glows,
    required this.intensity,
    required this.time,
    required this.animate,
  }) : super(repaint: animate ? time : null);

  final List<GlowConfig> glows;
  final double intensity;
  final ValueNotifier<double> time;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animate ? time.value : 0.0;

    for (var i = 0; i < glows.length; i++) {
      final glow = glows[i];

      // Each glow gets its own phase so they breathe out of sync.
      final pulse = math.sin(t * glow.pulseSpeed + i * 1.7);

      final opacity =
          ((glow.baseOpacity + pulse * glow.pulseStrength) * intensity).clamp(
            0.0,
            1.0,
          );
      final radius = size.width * glow.radiusFactor * (1 + pulse * 0.06);
      final center = Offset(
        size.width * glow.position.dx,
        size.height * glow.position.dy,
      );

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            glow.color.withValues(alpha: opacity),
            glow.color.withValues(alpha: opacity * 0.35),
            glow.color.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.animate != animate ||
      !_listEquals(oldDelegate.glows, glows);

  static bool _listEquals(List<GlowConfig> a, List<GlowConfig> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
