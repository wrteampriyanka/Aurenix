import 'package:flutter/material.dart';

import 'package:aurenix/core/theme/app_colors.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.showLineThrough = false,
    this.fontWeight,
    this.fontStyle,
    this.fontSize,
    this.textAlign,
    this.maxLines = 10,
    this.showUnderline = false,
    this.underlineOrLineColor,
    this.letterSpacing,
    this.textBaseline,
    this.textSpan,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final TextAlign? textAlign;
  final int maxLines;
  final bool showLineThrough;
  final bool showUnderline;
  final Color? underlineOrLineColor;
  final double? letterSpacing;
  final TextBaseline? textBaseline;

  /// When set, renders [Text.rich] with this span instead of [text].
  final InlineSpan? textSpan;

  @override
  Widget build(BuildContext context) {
    final decoration = showLineThrough
        ? TextDecoration.lineThrough
        : showUnderline
        ? TextDecoration.underline
        : null;

    final style = TextStyle(
      color: color ?? context.color.textPrimary,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize,
      decoration: decoration,
      decorationColor: underlineOrLineColor,
      height: 1.3,
      letterSpacing: letterSpacing,
      textBaseline: textBaseline,
    );

    if (textSpan != null) {
      return Text.rich(
        textSpan!,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: style,
        textAlign: textAlign,
      );
    }

    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: style,
      textAlign: textAlign,
    );
  }
}
