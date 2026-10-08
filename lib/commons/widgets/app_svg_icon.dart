import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An SVG from `assets/images` drawn like an [Icon]: square, sized in
/// logical pixels and tinted, so a drawn icon can stand in for a font one
/// anywhere a theme colour is expected.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.asset, {super.key, required this.size, this.color});

  final String asset;
  final double size;

  /// Replaces every colour in the file; null leaves the artwork as drawn.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
