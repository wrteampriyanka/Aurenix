import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../utils/elapsed_time_mixin.dart';

/// Bright blue orb inside a thin outer ring, with translucent waves that
/// keep flowing across its lower half and a gentle breathing glow.
///
/// The ring touches the bottom edge of the widget so a connector line can
/// start directly beneath it.
class WaveOrb extends StatefulWidget {
  const WaveOrb({super.key, this.size = 240});

  final double size;

  @override
  State<WaveOrb> createState() => _WaveOrbState();
}

class _WaveOrbState extends State<WaveOrb>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _WaveOrbPainter(
          time: time,
          bright: context.color.orbBright,
          base: context.color.orbBase,
          deep: context.color.primary,
          ring: context.color.orbRing,
        ),
      ),
    );
  }
}

class _WaveOrbPainter extends CustomPainter {
  _WaveOrbPainter({
    required this.time,
    required this.bright,
    required this.base,
    required this.deep,
    required this.ring,
  }) : super(repaint: time);

  final ValueNotifier<double> time;
  final Color bright;
  final Color base;
  final Color deep;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final center = size.center(Offset.zero);
    final ringRadius = size.width / 2 - 0.5;
    final radius = ringRadius * 0.8;
    final orbRect = Rect.fromCircle(center: center, radius: radius);

    // Soft breathing glow behind the orb.
    final glow = 0.35 + math.sin(t * 1.2) * 0.08;
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            bright.withValues(alpha: glow),
            deep.withValues(alpha: glow * 0.3),
            deep.withValues(alpha: 0),
          ],
          stops: const [0.6, 0.8, 1],
        ).createShader(Rect.fromCircle(center: center, radius: ringRadius)),
    );

    // Outer ring.
    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ring,
    );

    // Orb body: bright top-right fading to deeper blue at the bottom.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [bright, deep, base],
          stops: const [0, 0.45, 1],
        ).createShader(orbRect),
    );

    // Waves, clipped to the orb. They never stop moving.
    canvas.save();
    canvas.clipPath(Path()..addOval(orbRect));

    final waves = [
      // (baseline, amplitude, wavelength, speed, alpha)
      (-0.05, 0.16, 1.9, 0.9, 0.22),
      (0.18, 0.14, 1.5, -1.2, 0.28),
      (0.55, 0.10, 1.2, 1.6, 0.30),
    ];

    for (final (baseline, amplitude, wavelength, speed, alpha) in waves) {
      final path = _wavePath(
        orbRect,
        baselineY: center.dy + radius * baseline,
        amplitude: radius * amplitude,
        wavelength: radius * 2 * wavelength,
        phase: t * speed,
      );
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: alpha + 0.1),
              Colors.white.withValues(alpha: alpha * 0.5),
            ],
          ).createShader(orbRect),
      );
    }
    canvas.restore();
  }

  Path _wavePath(
    Rect bounds, {
    required double baselineY,
    required double amplitude,
    required double wavelength,
    required double phase,
  }) {
    final path = Path()..moveTo(bounds.left, bounds.bottom);
    const step = 3.0;
    for (var x = bounds.left; x <= bounds.right + step; x += step) {
      final y =
          baselineY +
          math.sin((x - bounds.left) / wavelength * 2 * math.pi + phase) *
              amplitude;
      path.lineTo(x, y);
    }
    return path
      ..lineTo(bounds.right, bounds.bottom)
      ..close();
  }

  @override
  bool shouldRepaint(_WaveOrbPainter oldDelegate) =>
      oldDelegate.bright != bright ||
      oldDelegate.base != base ||
      oldDelegate.deep != deep ||
      oldDelegate.ring != ring;
}
