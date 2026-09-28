import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/app_colors.dart';
import 'custom_text.dart';

/// Plain dark screen with a soft glow behind the status bar, used by the
/// form screens (reset password, edit profile).
class AppPlainBackground extends StatelessWidget {
  const AppPlainBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: ColoredBox(
        color: context.color.backgroundBase,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _TopGlow(),
            child,
          ],
        ),
      ),
    );
  }
}

/// Faint teal wash behind the status bar, a little right of centre and
/// gone before the screen title, as in the design.
class _TopGlow extends StatelessWidget {
  const _TopGlow();

  @override
  Widget build(BuildContext context) {
    final glow = context.color.topGlow;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.paddingOf(context).top + 110,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.3, -1.4),
              radius: 1.1,
              // Stretch the circle into a wide, shallow ellipse.
              transform: const _ScaleX(2.4),
              colors: [
                glow.withValues(alpha: 0.5),
                glow.withValues(alpha: 0.22),
                glow.withValues(alpha: 0.06),
                glow.withValues(alpha: 0),
              ],
              stops: const [0, 0.35, 0.7, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// Scales a gradient horizontally around the centre of its bounds.
class _ScaleX extends GradientTransform {
  const _ScaleX(this.factor);

  final double factor;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final cx = bounds.center.dx;
    return Matrix4.identity()
      ..translateByDouble(cx, 0, 0, 1)
      ..scaleByDouble(factor, 1, 1, 1)
      ..translateByDouble(-cx, 0, 0, 1);
  }
}

/// Round back button followed by the screen title.
class AppBackHeader extends StatelessWidget {
  const AppBackHeader({super.key, required this.title, this.onBack});

  final String title;

  /// Defaults to [Get.back].
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Material(
            color: context.color.inputFill,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onBack ?? Get.back,
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  PhosphorIconsRegular.caretLeft,
                  size: 20,
                  color: context.color.textNatural,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomText(
              title,
              maxLines: 1,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shell shared by the profile detail screens: plain background, back
/// header, a divider, a scrolling body and an optional pinned [bottom].
class AppDetailPage extends StatelessWidget {
  const AppDetailPage({
    super.key,
    required this.title,
    required this.child,
    this.header,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
  });

  final String title;

  /// Scrolling content below the divider.
  final Widget child;

  /// Pinned under the divider, above the scrolling content.
  final Widget? header;

  /// Pinned to the bottom of the screen, e.g. a save button.
  final Widget? bottom;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppPlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBackHeader(title: title),
              Divider(height: 1, color: context.color.strokeDark),
              ?header,
              Expanded(
                child: SingleChildScrollView(padding: padding, child: child),
              ),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
