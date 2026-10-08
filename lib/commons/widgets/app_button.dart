import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/utils/elapsed_time_mixin.dart';
import 'package:aurenix/commons/widgets/app_text.dart';

/// Primary pill button with a leading animated circular icon.
/// Uses the primary blue by default; pass [color], [highlightColor] and
/// [borderColor] for a different look (e.g. the dark upgrade button).
/// Pass `icon: null` for a plain text button without the leading circle.
///
/// While enabled, the leading circle emits a soft ripple ring and the icon
/// nudges forward; the whole button scales down slightly while pressed.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = PhosphorIconsRegular.arrowRight,
    this.height = 58,
    this.width = double.infinity,
    this.fontSize = 20,
    this.color,
    this.highlightColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double width;
  final double fontSize;

  /// Base of the gradient. Defaults to the primary blue.
  final Color? color;

  /// Top-left glow of the gradient. Defaults to the button highlight.
  final Color? highlightColor;
  final Color? borderColor;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin, ElapsedTimeMixin {
  static const double _circleSize = 26;

  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final radius = BorderRadius.circular(widget.height / 2);

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: widget.borderColor ?? appColors.buttonBorder,
            ),
            gradient: RadialGradient(
              center: const Alignment(-0.7, -1.4),
              radius: 1.6,
              colors: [
                widget.highlightColor ?? appColors.buttonHighlight,
                widget.color ?? appColors.primary,
              ],
              stops: const [0, 0.55],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: enabled ? (_) => _setPressed(true) : null,
              onTapUp: enabled ? (_) => _setPressed(false) : null,
              onTapCancel: () => _setPressed(false),
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon case final icon?) ...[
                      _AnimatedIconCircle(
                        time: time,
                        animate: enabled,
                        size: _circleSize,
                        icon: icon,
                      ),
                      const SizedBox(width: 18),
                    ],
                    Flexible(
                      child: AppText(
                        widget.label,
                        maxLines: 1,
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w400,
                        color: appColors.textNatural,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedIconCircle extends StatelessWidget {
  const _AnimatedIconCircle({
    required this.time,
    required this.animate,
    required this.size,
    required this.icon,
  });

  final ValueNotifier<double> time;
  final bool animate;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: appColors.primaryShade50,
        shape: BoxShape.circle,
      ),
      child: animate
          ? ValueListenableBuilder<double>(
              valueListenable: time,
              builder: (_, t, child) => Transform.translate(
                // Quick nudge forward, then rest.
                offset: Offset(
                  math.pow(math.max(0.0, math.sin(t * 3)), 3) * 2.5,
                  0,
                ),
                child: child,
              ),
              child: Icon(icon, size: 18, color: appColors.primary),
            )
          : Icon(icon, size: 18, color: appColors.primary),
    );

    if (!animate) return circle;

    // Keeps the per-frame ripple from repainting the rest of the screen
    // (e.g. a full-screen background shader) on every tick.
    return RepaintBoundary(
      child: CustomPaint(
        painter: _RipplePainter(time: time, color: appColors.primaryShade50),
        child: circle,
      ),
    );
  }
}

/// Two staggered rings that expand out of the icon circle and fade.
class _RipplePainter extends CustomPainter {
  _RipplePainter({required this.time, required this.color})
    : super(repaint: time);

  final ValueNotifier<double> time;
  final Color color;

  static const double _period = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final base = size.width / 2;

    for (final offset in const [0.0, 0.5]) {
      final progress = ((time.value / _period) + offset) % 1;
      final eased = Curves.easeOut.transform(progress);
      canvas.drawCircle(
        center,
        base + eased * base * 0.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * (1 - progress) + 0.5
          ..color = color.withValues(alpha: 0.6 * (1 - progress)),
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => oldDelegate.color != color;
}
