import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Slides [child] to the right to reveal [sidebar] underneath, dimming the
/// part of [child] still on screen, as in the design.
///
/// Driven by [animation] (0 closed, 1 open). A horizontal swipe opens and
/// closes it, and tapping the dimmed [child] closes it.
class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({
    super.key,
    required this.animation,
    required this.sidebar,
    required this.child,
  });

  final AnimationController animation;
  final Widget sidebar;
  final Widget child;

  static const double _maxWidth = 320;
  static const double _widthFactor = 0.82;

  /// Fling speed (px/s) that settles the drawer in the fling direction.
  static const double _flingVelocity = 365;

  void _onDragUpdate(DragUpdateDetails details, double width) {
    animation.value += details.primaryDelta! / width;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() >= _flingVelocity) {
      velocity > 0 ? animation.forward() : animation.reverse();
    } else {
      animation.value > 0.5 ? animation.forward() : animation.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(
            constraints.maxWidth * _widthFactor,
            _maxWidth,
          );
          return GestureDetector(
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
            onHorizontalDragEnd: _onDragEnd,
            child: ColoredBox(
              color: context.color.sidebarBackground,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final t = Curves.easeOut.transform(animation.value);
                  return Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        width: width,
                        // Kept alive but out of reach while fully covered.
                        child: Visibility(
                          visible: animation.value > 0,
                          maintainState: true,
                          child: Transform.translate(
                            offset: Offset(-(1 - t) * width * 0.3, 0),
                            child: sidebar,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(t * width, 0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              child,
                              if (animation.value > 0)
                                GestureDetector(
                                  onTap: animation.reverse,
                                  child: ColoredBox(
                                    color: context.color.sidebarScrim
                                        .withValues(
                                          alpha:
                                              context.color.sidebarScrim.a * t,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
