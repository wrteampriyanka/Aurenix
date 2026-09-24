import 'dart:math' as math;

import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../utils/elapsed_time_mixin.dart';
import 'k_glowing_blurs.dart';

/// Shared dark screen background: gradient + twinkling dot matrix + glows.
///
/// Wrap any screen body with it:
/// ```dart
/// Scaffold(body: AppBackground(child: ...))
/// ```
/// Pass [glows] to use a per-screen glow layout.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.glows,
    this.showGrid = true,
  });

  final Widget child;
  final List<GlowConfig>? glows;
  final bool showGrid;

  static List<GlowConfig> defaultGlows(BuildContext context) => [
    GlowConfig(
      position: const Offset(0.35, -0.02),
      radiusFactor: 1.3,
      color: context.color.backgroundGlow,
      baseOpacity: 0.85,
      pulseStrength: 0.1,
      pulseSpeed: 0.8,
    ),
    GlowConfig(
      position: const Offset(0.95, 0.45),
      radiusFactor: 0.55,
      color: context.color.accentPurple,
      baseOpacity: 0.18,
      pulseStrength: 0.08,
      pulseSpeed: 0.6,
    ),
    GlowConfig(
      position: const Offset(0.05, 0.85),
      radiusFactor: 0.7,
      color: context.color.primary,
      baseOpacity: 0.2,
      pulseStrength: 0.08,
      pulseSpeed: 0.7,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.color.backgroundDarkSecondary,
              context.color.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            KGlowingBlurs(glows: glows ?? defaultGlows(context)),
            if (showGrid) const _DotMatrix(),
            child,
          ],
        ),
      ),
    );
  }
}

/// Fine dot matrix (small squares) with a few dots twinkling at a time.
class _DotMatrix extends StatefulWidget {
  const _DotMatrix();

  @override
  State<_DotMatrix> createState() => _DotMatrixState();
}

class _DotMatrixState extends State<_DotMatrix>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  @override
  Widget build(BuildContext context) {
    final dotColor = context.color.textNatural;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static dots: painted once, never repainted by the ticker.
          RepaintBoundary(
            child: CustomPaint(painter: _DotPainter(color: dotColor)),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: _DotPainter(color: dotColor, time: time),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.color, this.time}) : super(repaint: time);

  final Color color;

  /// When set, paints only the twinkling subset; otherwise the static layer.
  final ValueNotifier<double>? time;

  static const double _spacing = 7;
  static const double _dot = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / _spacing).ceil();
    final rows = (size.height / _spacing).ceil();

    // Visible mostly around the upper-middle, fading towards the edges.
    final mask = RadialGradient(
      center: const Alignment(0.2, -0.3),
      radius: 1.0,
      colors: [color, color.withValues(alpha: 0)],
    ).createShader(Offset.zero & size);

    final t = time?.value;
    if (t == null) {
      final points = <Offset>[
        for (var r = 0; r < rows; r++)
          for (var c = 0; c < cols; c++)
            Offset(c * _spacing + _spacing / 2, r * _spacing + _spacing / 2),
      ];
      canvas.saveLayer(Offset.zero & size, Paint());
      canvas.drawPoints(
        PointMode.points,
        points,
        Paint()
          ..strokeWidth = _dot
          ..strokeCap = StrokeCap.square
          ..color = color.withValues(alpha: 0.10),
      );
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = mask
          ..blendMode = BlendMode.dstIn,
      );
      canvas.restore();
      return;
    }

    final paint = Paint();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final seed = _hash(c, r);
        if (seed % 9 != 0) continue; // Only ~11% of dots can twinkle.

        final speed = 0.4 + (seed % 100) / 100 * 0.6;
        final phase = (seed % 628) / 100;
        final wave = math.sin(t * speed + phase);
        final glow = math.pow(math.max(0.0, wave), 16).toDouble();
        if (glow < 0.05) continue;

        final p = Offset(
          c * _spacing + _spacing / 2,
          r * _spacing + _spacing / 2,
        );
        final edge =
            (1 -
                    (p - Offset(size.width * 0.6, size.height * 0.35))
                            .distance /
                        (size.longestSide * 0.6))
                .clamp(0.0, 1.0);
        paint.color = color.withValues(alpha: glow * 0.55 * edge);
        canvas.drawRect(
          Rect.fromCenter(center: p, width: _dot * 1.6, height: _dot * 1.6),
          paint,
        );
      }
    }
  }

  static int _hash(int x, int y) {
    var h = x * 374761393 + y * 668265263;
    h = (h ^ (h >> 13)) * 1274126177;
    return (h ^ (h >> 16)) & 0x7fffffff;
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.time != time;
}
