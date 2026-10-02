import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Slides [sidebar] in from the left over [child], which stays in place and
/// is dimmed behind it.
///
/// Driven by [animation] (0 closed, 1 open). A horizontal swipe opens and
/// closes it, and tapping the dimmed [child] closes it.
///
/// [expand] (0 drawer, 1 full screen) widens the open sidebar to cover the
/// whole screen, e.g. for search. Swiping is off meanwhile.
class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({
    super.key,
    required this.animation,
    required this.expand,
    required this.sidebar,
    required this.child,
  });

  final AnimationController animation;
  final Animation<double> expand;
  final Widget sidebar;
  final Widget child;

  static const double _maxWidth = 320;
  static const double _widthFactor = 0.82;

  /// Fling speed (px/s) that settles the drawer in the fling direction.
  static const double _flingVelocity = 365;

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (!expand.isDismissed) return;
    animation.value += details.primaryDelta! / width;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!expand.isDismissed) return;
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
          final drawerWidth = math.min(
            constraints.maxWidth * _widthFactor,
            _maxWidth,
          );
          return GestureDetector(
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, drawerWidth),
            onHorizontalDragEnd: _onDragEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([animation, expand]),
              builder: (context, _) {
                final t = Curves.easeOut.transform(animation.value);
                final e = Curves.easeInOutCubic.transform(expand.value);
                final width = lerpDouble(drawerWidth, constraints.maxWidth, e)!;
                return Stack(
                  children: [
                    Positioned.fill(child: child),
                    if (animation.value > 0)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: animation.reverse,
                          child: ColoredBox(
                            color: context.color.sidebarScrim.withValues(
                              alpha: context.color.sidebarScrim.a * t,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: width,
                      // Kept alive but out of reach while fully hidden.
                      child: Visibility(
                        visible: animation.value > 0,
                        maintainState: true,
                        child: Transform.translate(
                          offset: Offset(-(1 - t) * width, 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.color.sidebarBackground,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.25 * t,
                                  ),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: sidebar,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
