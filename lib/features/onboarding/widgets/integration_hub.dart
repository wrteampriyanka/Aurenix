import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/elapsed_time_mixin.dart';

/// App icon in the centre, connected to four platform tiles (two per side)
/// by bracket-shaped lines, with a stem going up to the orb above.
///
/// Tiles keep fixed positions; small light pulses travel along the
/// connectors from each platform into the app icon.
///
/// Layout (dp, width 310):
/// ```
///                 │  stem
///  [ClickUp]──┐   │   ┌──[Notion]
///             ├─[App]─┤
///  [Figma]  ──┘       └──[Jira]
/// ```
class IntegrationHub extends StatefulWidget {
  const IntegrationHub({super.key});

  static const double width = 310;
  static const double height = 168;

  // Geometry.
  static const double stemHeight = 62;
  static const double tileSize = 48;
  static const double centerSize = 78;
  static const double busInset = 75;
  static const double topTileY = 35;
  static const double bottomTileY = 120;

  @override
  State<IntegrationHub> createState() => _IntegrationHubState();
}

class _IntegrationHubState extends State<IntegrationHub>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  @override
  Widget build(BuildContext context) {
    const w = IntegrationHub.width;
    const tile = IntegrationHub.tileSize;
    const center = IntegrationHub.centerSize;

    return SizedBox(
      width: w,
      height: IntegrationHub.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ConnectorPainter(
                  time: time,
                  lineColor: context.color.connectorLine,
                  pulseColor: context.color.orbLight,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            top: IntegrationHub.topTileY,
            child: _PlatformTile(asset: AppAssets.clickupLogo, size: tile),
          ),
          const Positioned(
            left: 0,
            top: IntegrationHub.bottomTileY,
            child: _PlatformTile(asset: AppAssets.figmaLogo, size: tile),
          ),
          const Positioned(
            right: 0,
            top: IntegrationHub.topTileY,
            child: _PlatformTile(asset: AppAssets.notionLogo, size: tile),
          ),
          const Positioned(
            right: 0,
            top: IntegrationHub.bottomTileY,
            child: _PlatformTile(asset: AppAssets.jiraLogo, size: tile),
          ),
          Positioned(
            left: (w - center) / 2,
            top: IntegrationHub.stemHeight,
            child: const _AppIconTile(size: center),
          ),
        ],
      ),
    );
  }
}

class _TileFrame extends StatelessWidget {
  const _TileFrame({
    required this.size,
    required this.radius,
    required this.child,
    this.highlighted = false,
  });

  final double size;
  final double radius;
  final bool highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: context.color.tileFill,
        gradient: highlighted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.color.tileFillHighlight,
                  context.color.tileFill,
                ],
              )
            : null,
        border: Border.all(color: context.color.tileBorder),
      ),
      child: child,
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      size: size,
      radius: 12,
      child: SvgPicture.asset(
        asset,
        width: size * 0.46,
        height: size * 0.46,
        colorFilter: ColorFilter.mode(
          context.color.platformIcon,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _AppIconTile extends StatelessWidget {
  const _AppIconTile({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      size: size,
      radius: 20,
      highlighted: true,
      child: Image.asset(
        AppAssets.appIcon,
        width: size * 0.5,
        color: context.color.appIconMuted,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.time,
    required this.lineColor,
    required this.pulseColor,
  }) : super(repaint: time);

  final ValueNotifier<double> time;
  final Color lineColor;
  final Color pulseColor;

  /// Seconds for a pulse to travel one connector.
  static const double _period = 2.4;

  // Paths and their metrics only depend on size, so they are measured once
  // instead of on every animation frame.
  Size? _cachedSize;
  List<Path> _paths = const [];
  List<PathMetric> _metrics = const [];

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _cachedSize) {
      _cachedSize = size;
      _paths = _connectorPaths(size);
      _metrics = [for (final p in _paths) p.computeMetrics().first];
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = lineColor;
    for (final path in _paths) {
      canvas.drawPath(path, linePaint);
    }

    // Travelling pulses, staggered per connector. The soft halo is a radial
    // gradient rather than a blur mask filter, which is far cheaper per frame.
    const glowRadius = 5.0;
    final glowPaint = Paint();
    final dotPaint = Paint();
    for (var i = 0; i < _metrics.length; i++) {
      final metric = _metrics[i];
      final progress = ((time.value / _period) + i / _metrics.length) % 1;
      final tangent = metric.getTangentForOffset(
        metric.length * Curves.easeInOut.transform(progress),
      );
      if (tangent == null) continue;

      // Fade in at the start and out on arrival.
      final fade = (progress < 0.15
          ? progress / 0.15
          : progress > 0.85
          ? (1 - progress) / 0.15
          : 1.0);
      final p = tangent.position;
      glowPaint.shader = RadialGradient(
        colors: [
          pulseColor.withValues(alpha: 0.6 * fade),
          pulseColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: p, radius: glowRadius));
      dotPaint.color = pulseColor.withValues(alpha: 0.9 * fade);
      canvas.drawCircle(p, glowRadius, glowPaint);
      canvas.drawCircle(p, 1.5, dotPaint);
    }
  }

  /// Each path runs from a source (platform tile / orb) into the app icon.
  List<Path> _connectorPaths(Size size) {
    const tile = IntegrationHub.tileSize;
    const bus = IntegrationHub.busInset;
    const topY = IntegrationHub.topTileY + tile / 2;
    const bottomY = IntegrationHub.bottomTileY + tile / 2;
    const centerY = IntegrationHub.stemHeight + IntegrationHub.centerSize / 2;

    final w = size.width;
    final midX = w / 2;
    final centerLeft = midX - IntegrationHub.centerSize / 2;
    final centerRight = midX + IntegrationHub.centerSize / 2;

    Path fromLeft(double y) => Path()
      ..moveTo(tile, y)
      ..lineTo(bus, y)
      ..lineTo(bus, centerY)
      ..lineTo(centerLeft, centerY);

    Path fromRight(double y) => Path()
      ..moveTo(w - tile, y)
      ..lineTo(w - bus, y)
      ..lineTo(w - bus, centerY)
      ..lineTo(centerRight, centerY);

    return [
      // Stem from the orb ring down into the app icon.
      Path()
        ..moveTo(midX, 0)
        ..lineTo(midX, IntegrationHub.stemHeight),
      fromLeft(topY),
      fromRight(topY),
      fromLeft(bottomY),
      fromRight(bottomY),
    ];
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.pulseColor != pulseColor;
}
