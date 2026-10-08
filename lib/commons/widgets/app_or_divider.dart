import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Dashed horizontal line with an "OR" pill in the middle.
class AppOrDivider extends StatelessWidget {
  const AppOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: CustomPaint(
        size: const Size.fromHeight(1),
        painter: _DashedLinePainter(color: appColors.divider),
      ),
    );

    return Row(
      children: [
        line,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: appColors.backgroundBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: appColors.divider),
          ),
          child: AppText(
            AppStrings.or.tr,
            fontSize: AppFontSize.overline,
            color: appColors.textBody,
          ),
        ),
        line,
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final y = size.height / 2;
    for (var x = 0.0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(Offset(x, y), Offset(x + _dash, y), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
