import 'package:flutter/material.dart';

import 'package:aurenix/core/theme/app_colors.dart';

class AppText extends StatelessWidget {
  const AppText(
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
  }) : textSpan = null;

  /// Renders [span] instead of a plain string, for text with links or mixed
  /// styling. Avoids the empty positional [text] the plain constructor would
  /// otherwise need.
  const AppText.rich(
    InlineSpan span, {
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
  }) : textSpan = span,
       text = '';

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

  /// Set by [AppText.rich]; null for the plain constructor.
  final InlineSpan? textSpan;

  @override
  Widget build(BuildContext context) {
    final decoration = showLineThrough
        ? TextDecoration.lineThrough
        : showUnderline
        ? TextDecoration.underline
        : null;

    final style = TextStyle(
      color: color ?? appColors.textPrimary,
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
