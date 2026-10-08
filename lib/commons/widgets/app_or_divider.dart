import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';

/// Dashed horizontal line with an "OR" pill in the middle.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: CustomPaint(
        size: const Size.fromHeight(1),
        painter: _DashedLinePainter(color: context.color.divider),
      ),
    );

    return Row(
      children: [
        line,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: context.color.backgroundBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.color.divider),
          ),
          child: CustomText(
            'or'.tr,
            fontSize: 12,
            color: context.color.textBody,
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
