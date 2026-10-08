import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/widgets/app_detail_app_bar.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// Plain dark screen with a soft glow behind the status bar, used by the
/// form screens (reset password, edit profile). The glow is teal unless
/// [glow] says otherwise (the preset detail screen uses blue).
class AppPlainBackground extends StatelessWidget {
  const AppPlainBackground({super.key, required this.child, this.glow});

  final Widget child;
  final Color? glow;

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
            _TopGlow(color: glow ?? context.color.topGlow),
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
  const _TopGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.paddingOf(context).top + 110,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: topGlowGradient(color)),
        ),
      ),
    );
  }
}

/// The teal glow painted behind the status bar, stretched into a wide,
/// shallow ellipse.
Gradient topGlowGradient(Color glow) {
  return RadialGradient(
    center: const Alignment(0.3, -1.4),
    radius: 1.1,
    transform: const _ScaleX(2.4),
    colors: [
      glow.withValues(alpha: 0.5),
      glow.withValues(alpha: 0.22),
      glow.withValues(alpha: 0.06),
      glow.withValues(alpha: 0),
    ],
    stops: const [0, 0.35, 0.7, 1],
  );
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

/// Round back button followed by the screen [title] (if any) and an
/// optional [action].
class AppBackHeader extends StatelessWidget {
  const AppBackHeader({super.key, this.title, this.onBack, this.action});

  final String? title;

  /// Defaults to [Get.back].
  final VoidCallback? onBack;

  /// Shown at the end of the row, e.g. a "Create New" button.
  final Widget? action;

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
              title ?? '',
              maxLines: 1,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.color.textNatural,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Shell shared by the profile detail screens: plain background, the
/// rounded [AppDetailAppBar], a scrolling body and an optional pinned [bottom].
class AppDetailPage extends StatelessWidget {
  const AppDetailPage({
    super.key,
    required this.title,
    required this.child,
    this.header,
    this.bottom,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 16),
  });

  final String title;

  /// Scrolling content below the app bar.
  final Widget child;

  /// Pinned under the app bar, above the scrolling content.
  final Widget? header;

  /// Pinned to the bottom of the screen, e.g. a save button.
  final Widget? bottom;

  /// Shown at the end of the app bar, e.g. a "Create New" button.
  final Widget? action;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundBase,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDetailAppBar(title: title, action: action),
            Expanded(
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ?header,
                    Expanded(
                      child: SingleChildScrollView(
                        padding: padding,
                        child: child,
                      ),
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
          ],
        ),
      ),
    );
  }
}
