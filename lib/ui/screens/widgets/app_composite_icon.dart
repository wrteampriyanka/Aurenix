import 'package:flutter/material.dart';

/// Two Phosphor glyphs drawn as one icon: [overlay] is drawn small over the
/// centre of [icon], shifted by [overlayOffset] in logical pixels at a
/// 22-pixel size and scaled with [size].
///
/// Used for icons Phosphor does not ship as a single glyph, such as a chat
/// bubble with a plus or an arrow inside.
class AppCompositeIcon extends StatelessWidget {
  const AppCompositeIcon({
    super.key,
    required this.icon,
    required this.overlay,
    required this.color,
    this.size = 22,
    this.overlayScale = 0.45,
    // The chat bubble's body sits a touch above and right of centre, away
    // from its tail, so the default nudges the overlay to match.
    this.overlayOffset = const Offset(0.5, -1),
  });

  final IconData icon;
  final IconData overlay;
  final Color color;
  final double size;
  final double overlayScale;
  final Offset overlayOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: size, color: color),
          Transform.translate(
            offset: overlayOffset * (size / 22),
            child: Icon(overlay, size: size * overlayScale, color: color),
          ),
        ],
      ),
    );
  }
}
