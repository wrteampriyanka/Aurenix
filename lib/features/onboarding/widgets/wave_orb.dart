import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../utils/elapsed_time_mixin.dart';

/// Bright blue orb inside a thin outer ring, with three translucent waves
/// braided together whose crests stay in place and rise and settle one
/// after another, and a breathing glow.
///
/// The ring touches the bottom edge of the widget so a connector line can
/// start directly beneath it.
///
/// Set [showRing] to false to drop the ring and let the orb fill [size],
/// and [showDots] to add a faint dot matrix inside the orb (home screen).
/// [speed] scales how fast the waves and glow move (1 is the default pace).
class WaveOrb extends StatefulWidget {
  const WaveOrb({
    super.key,
    this.size = 240,
    this.showRing = true,
    this.showDots = false,
    this.speed = 1,
  });

  final double size;
  final bool showRing;
  final bool showDots;
  final double speed;

  @override
  State<WaveOrb> createState() => _WaveOrbState();
}

class _WaveOrbState extends State<WaveOrb>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  // The flowing waves are the orb's core visual, so keep them moving.
  @override
  bool get respectsReduceMotion => false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _WaveOrbPainter(
            time: time,
            bright: context.color.orbBright,
            base: context.color.orbBase,
            deep: context.color.primary,
            ring: context.color.orbRing,
            showRing: widget.showRing,
            showDots: widget.showDots,
            speed: widget.speed,
          ),
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
    required this.showRing,
    required this.showDots,
    required this.speed,
  }) : super(repaint: time);

  final ValueNotifier<double> time;
  final Color bright;
  final Color base;
  final Color deep;
  final Color ring;
  final bool showRing;
  final bool showDots;
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value * speed;
    final center = size.center(Offset.zero);
    final ringRadius = size.width / 2 - 0.5;
    final radius = showRing ? ringRadius * 0.8 : size.width / 2;
    final orbRect = Rect.fromCircle(center: center, radius: radius);

    // Soft, blurred breathing glow behind the orb, pulsing with the waves.
    final pulse = 0.5 + 0.5 * math.sin(t * _pulseSpeed);
    canvas.drawCircle(
      center,
      radius * 1.02,
      Paint()
        ..color = bright.withValues(alpha: 0.16 + 0.08 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.22),
    );

    // Outer ring: brightest at the top, fading out towards the bottom so it
    // blends into the background instead of reading as a hard circle.
    if (showRing) {
      canvas.drawCircle(
        center,
        ringRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ring,
              ring.withValues(alpha: ring.a * 0.5),
              ring.withValues(alpha: 0.02),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: center, radius: ringRadius)),
      );
    }

    // Orb body: vivid cyan light pooling at the top, deepening to royal
    // blue towards the bottom-left.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.25, -0.75),
          radius: 1.35,
          colors: [bright, bright, base, deep],
          stops: const [0, 0.25, 0.65, 1],
        ).createShader(orbRect),
    );

    // Soft highlight near the top, like light catching a glass sphere.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, -0.85),
          radius: 0.75,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(orbRect),
    );

    // Waves, clipped to the orb. They stay in place and move up and down
    // instead of scrolling away.
    canvas.save();
    canvas.clipPath(Path()..addOval(orbRect));

    // All values are in units of the orb radius, measured from its centre
    // (y grows downwards). Drawn back to front.
    //
    // The two light waves form one pattern: they share a wavelength and
    // are shifted half a wave apart so the crests interlock like a braid.
    // Their lines only ever cross, never lie on top of each other. The
    // deep blue hump sits low beneath them. All three share the same
    // height and motion, and each moves opposite to its neighbour.
    const p = -0.906;
    final waves = [
      // Middle light wave: mirror of the top one, its trough under the top
      // crest.
      _Wave(
        level: 0.16,
        amplitude: 0.26,
        phase: p + math.pi,
        rise: -1,
        color: Colors.white,
        alpha: 0.24,
      ),
      // Top light wave: the big crest just left of centre.
      _Wave(
        level: 0.0,
        amplitude: 0.26,
        rise: 1,
        phase: p,
        color: Colors.white,
        alpha: 0.24,
      ),
      // Deeper blue hump along the base, as in the design. Moves just as
      // much as the light waves, opposite to the middle one.
      _Wave(
        level: 0.83,
        amplitude: 0.26,
        wavelength: 2.4,
        phase: -1.728,
        rise: 1,
        color: deep,
        alpha: 0.55,
      ),
    ];

    // Ramp in on real time so a faster orb still eases in over 2 s.
    final ramp = _rampIn(time.value);
    for (final wave in waves) {
      final k = 2 * math.pi / (wave.wavelength ?? _wavelength);
      // The crests stay fixed in place; nothing slides left or right.
      // Only their height changes:
      // - a slow swell runs along the row, so the crests rise one after
      //   another and then settle, like a crowd wave, never all at once;
      // - the whole wave also gently breathes taller and shorter.
      // Height stays between about 40% and 160%, so a wave never goes
      // flat. The waves are opposite: wherever the top wave grows the
      // middle one shrinks, and the blue hump grows with the top wave.
      // Because crests never move, the two light waves, half a wave
      // apart, can never line up on top of each other.
      double heightAt(double u) =>
          1 +
          wave.rise *
              (0.45 * math.sin(_rowK * u - t * _rowSpeed) +
                  0.15 * math.sin(t * _heightSpeed)) *
              ramp;

      double yAt(double u) =>
          wave.level +
          wave.amplitude * heightAt(u) * math.sin(k * u + wave.phase);

      final path =
          Path.from(
              _curvePath(orbRect, center: center, radius: radius, yAt: yAt),
            )
            ..lineTo(orbRect.right + _step, orbRect.bottom)
            ..lineTo(orbRect.left, orbRect.bottom)
            ..close();

      // Clean, flat translucent fill like the design.
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              wave.color.withValues(alpha: wave.alpha),
              wave.color.withValues(alpha: wave.alpha * 0.85),
            ],
          ).createShader(orbRect),
      );
    }

    if (showDots) _paintDots(canvas, orbRect);

    canvas.restore();
  }

  /// Faint dot matrix over the orb, fading in from left to right.
  void _paintDots(Canvas canvas, Rect orbRect) {
    if (orbRect != _dotsRect) {
      _dotsRect = orbRect;
      final points = <Offset>[];
      for (
        var y = orbRect.top + _dotSpacing / 2;
        y < orbRect.bottom;
        y += _dotSpacing
      ) {
        for (
          var x = orbRect.left + _dotSpacing / 2;
          x < orbRect.right;
          x += _dotSpacing
        ) {
          points.add(Offset(x, y));
        }
      }
      _dots = points;
    }

    canvas.drawPoints(
      PointMode.points,
      _dots,
      Paint()
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.square
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.28),
          ],
          stops: const [0.2, 0.5, 1],
        ).createShader(orbRect),
    );
  }

  static const _dotSpacing = 6.0;
  Rect? _dotsRect;
  List<Offset> _dots = const [];

  static const _step = 5.0;

  /// Radians per second of the glow's breathing (about 3.5 s a cycle).
  static const _pulseSpeed = 1.8;

  /// Shared length of the three waves, in orb radii.
  static const _wavelength = 1.7;

  /// Spatial frequency of the swell that runs along the row: one rise
  /// spans about two crests.
  static const _rowK = math.pi / _wavelength;

  /// Radians per second the swell runs along the row (about 3.5 s a cycle).
  static const _rowSpeed = 1.8;

  /// Radians per second of the height growing and shrinking (about 4 s a
  /// cycle).
  static const _heightSpeed = 1.5;

  /// Eases the motion in over the first 2 s so the opening frame is the
  /// exact design shape and motion starts without a jump.
  static double _rampIn(double t) =>
      Curves.easeInOut.transform((t / 2).clamp(0.0, 1.0));

  /// Open path tracing `y = yAt(u)` across [bounds], with u, y in radius
  /// units from the orb centre. Joined with quadratic curves for a smooth
  /// outline.
  Path _curvePath(
    Rect bounds, {
    required Offset center,
    required double radius,
    required double Function(double u) yAt,
  }) {
    Offset pointAt(double x) =>
        Offset(x, center.dy + radius * yAt((x - center.dx) / radius));

    var prev = pointAt(bounds.left);
    final path = Path()..moveTo(prev.dx, prev.dy);
    for (var x = bounds.left + _step; x <= bounds.right + _step; x += _step) {
      final next = pointAt(x);
      final mid = Offset.lerp(prev, next, 0.5)!;
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      prev = next;
    }
    return path..lineTo(prev.dx, prev.dy);
  }

  @override
  bool shouldRepaint(_WaveOrbPainter oldDelegate) =>
      oldDelegate.bright != bright ||
      oldDelegate.base != base ||
      oldDelegate.deep != deep ||
      oldDelegate.ring != ring ||
      oldDelegate.showRing != showRing ||
      oldDelegate.showDots != showDots ||
      oldDelegate.speed != speed;
}

@immutable
class _Wave {
  const _Wave({
    required this.level,
    required this.amplitude,
    required this.phase,
    required this.color,
    required this.alpha,
    this.wavelength,
    this.rise = 0,
  });

  final double level;
  final double amplitude;
  final double phase;
  final Color color;
  final double alpha;

  /// Own length in orb radii; null to share the braid's length.
  final double? wavelength;

  /// Which way this wave's height moves: 1 grows where the top wave
  /// grows, -1 shrinks there.
  final double rise;
}
