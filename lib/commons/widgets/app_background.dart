import 'dart:math' as math;

import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/elapsed_time_mixin.dart';
import 'package:aurenix/features/widgets/k_glowing_blurs.dart';

/// Shared dark screen background: gradient + twinkling dot matrix + glows.
///
/// Wrap any screen body with it:
/// ```dart
/// Scaffold(body: AppBackground(child: ...))
/// ```
/// By default the top of the screen is the deep blue band from the design
/// (see [_DeepTop]). Onboarding sets [deepTop] to false and keeps its softer
/// fade, because the orb already lights the top of that screen.
/// Pass [glows] to add optional per-screen glows.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.glows,
    this.showGrid = true,
    this.gridOverContent = true,
    this.deepTop = true,
  });

  final Widget child;
  final List<GlowConfig>? glows;
  final bool showGrid;

  /// Paints the dot grid over [child] (so it shows on the onboarding orb).
  /// Set to false to keep it behind the content, e.g. under form fields.
  final bool gridOverContent;

  /// Deep blue band at the top of the screen, as on the auth screens.
  final bool deepTop;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: deepTop
            ? BoxDecoration(color: context.color.backgroundBase)
            : BoxDecoration(
                // Blue at the top, easing smoothly into the flat dark base.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.color.backgroundTop,
                    Color.lerp(
                      context.color.backgroundTop,
                      context.color.backgroundTopFade,
                      0.6,
                    )!,
                    context.color.backgroundTopFade,
                    Color.lerp(
                      context.color.backgroundTopFade,
                      context.color.backgroundBase,
                      0.6,
                    )!,
                    context.color.backgroundBase,
                  ],
                  stops: const [0, 0.12, 0.24, 0.36, 0.5],
                ),
              ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (deepTop) const _DeepTop(),
            if (glows case final glows? when glows.isNotEmpty)
              KGlowingBlurs(glows: glows),
            if (showGrid && !gridOverContent) const _DotMatrix(),
            child,
            // Drawn over the content so the dots also show on the orb.
            if (showGrid && gridOverContent) const _DotMatrix(),
          ],
        ),
      ),
    );
  }
}

/// Blue band across the top of the screen, matched to the design: bright
/// blue under the status bar, a little lighter left of centre and darker
/// towards the right edge, fading into the base by ~32% of the height so
/// the screen title already sits on the dark base.
class _DeepTop extends StatelessWidget {
  const _DeepTop();

  /// Opacity of the band from the top of the screen down.
  static const _fadeStops = [
    0.0, 0.05, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.22, //
    0.25, 0.28, 0.32,
  ];
  static const _fadeAlphas = [
    1.0, 1.0, 0.95, 0.88, 0.8, 0.66, 0.54, 0.42, 0.3, 0.2, //
    0.11, 0.05, 0.0,
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            for (final a in _fadeAlphas) Colors.white.withValues(alpha: a),
          ],
          stops: _fadeStops,
        ).createShader(bounds),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.color.backgroundTopBand,
              stops: const [0, 0.11, 0.26, 0.51, 0.72, 0.92, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fine dot matrix (small squares) with a few dots twinkling at a time.
/// Hidden under the status bar, fading in below it and out towards the
/// middle of the screen.
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

  /// Dots are invisible above this fraction of the screen height...
  static const double _fadeInStart = 0.08;

  /// ...fully visible from here...
  static const double _fadeInEnd = 0.2;

  /// ...and fade out completely by this fraction.
  static const double _fadeEnd = 0.55;

  /// Start of the fade-out, as a fraction of the screen height.
  static const double _fadeOutStart = _fadeEnd * 0.7;

  /// 0 under the status bar, 1 in the band around the orb, 0 at [_fadeEnd].
  static double _verticalFade(double y, double height) {
    final f = y / height;
    if (f <= _fadeInStart || f >= _fadeEnd) return 0;
    if (f < _fadeInEnd) {
      return (f - _fadeInStart) / (_fadeInEnd - _fadeInStart);
    }
    if (f <= _fadeOutStart) return 1;
    return 1 - (f - _fadeOutStart) / (_fadeEnd - _fadeOutStart);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / _spacing).ceil();
    final rows = (size.height * _fadeEnd / _spacing).ceil();

    // Fades in below the status bar and out towards [_fadeEnd].
    final clear = color.withValues(alpha: 0);
    final mask = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [clear, clear, color, color, clear],
      stops: const [0, _fadeInStart, _fadeInEnd, _fadeOutStart, _fadeEnd],
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

    if (size != _cachedSize) {
      _cachedSize = size;
      _twinkles = _buildTwinkles(size, cols, rows);
    }

    final paint = Paint();
    const side = _dot * 1.6;
    for (final d in _twinkles) {
      final wave = math.sin(t * d.speed + d.phase);
      if (wave <= 0) continue;
      final glow = math.pow(wave, 16).toDouble();
      if (glow < 0.01) continue;

      paint.color = color.withValues(alpha: glow * 0.3 * d.edge);
      canvas.drawRect(
        Rect.fromCenter(center: d.position, width: side, height: side),
        paint,
      );
    }
  }

  // Twinkle candidates only depend on size, so they are computed once
  // instead of scanning every dot on every frame.
  Size? _cachedSize;
  List<_Twinkle> _twinkles = const [];

  static List<_Twinkle> _buildTwinkles(Size size, int cols, int rows) {
    return [
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++)
          if (_hash(c, r) % 9 == 0) // Only ~11% of dots can twinkle.
            _twinkleAt(c, r, size.height),
    ].where((d) => d.edge > 0).toList(growable: false);
  }

  static _Twinkle _twinkleAt(int c, int r, double height) {
    final seed = _hash(c, r);
    final position = Offset(
      c * _spacing + _spacing / 2,
      r * _spacing + _spacing / 2,
    );
    return _Twinkle(
      position: position,
      speed: 0.4 + (seed % 100) / 100 * 0.6,
      phase: (seed % 628) / 100,
      edge: _verticalFade(position.dy, height),
    );
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

class _Twinkle {
  const _Twinkle({
    required this.position,
    required this.speed,
    required this.phase,
    required this.edge,
  });

  final Offset position;
  final double speed;
  final double phase;

  /// Fade factor towards the bottom of the dot area (0 → invisible).
  final double edge;
}
