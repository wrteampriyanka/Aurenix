import 'package:flutter/material.dart';

/// Fades and slides [children] up one after another as the sheet opens,
/// driven by the sheet's own route animation so closing plays it back.
///
/// [step] is the delay between neighbours; a sheet with more rows uses a
/// smaller one so the last row is not left behind.
List<Widget> staggeredSheetRows(
  BuildContext context,
  List<Widget> children, {
  double step = 0.1,
}) {
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null) return children;
  const span = 0.5;
  return [
    for (var i = 0; i < children.length; i++)
      _Reveal(
        animation: animation.drive(
          CurveTween(
            curve: Interval(
              (0.15 + i * step).clamp(0.0, 1 - span),
              (0.15 + i * step + span).clamp(span, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: children[i],
      ),
  ];
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  /// 0 hidden, 1 in place.
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.3), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
