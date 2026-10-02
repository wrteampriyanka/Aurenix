import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Dark filled input with an optional leading icon, used on the form screens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.controller,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.focusNode,
  });

  final String hint;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  /// Pass more than 1 (or null to grow freely) for a multi-line field.
  final int? maxLines;
  final int? minLines;

  /// Shows the value but refuses edits and never opens the keyboard.
  final bool readOnly;

  /// Lets the caller move focus here, e.g. once a sheet has opened.
  final FocusNode? focusNode;

  static const double _radius = 14;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_radius),
    borderSide: BorderSide(color: color),
  );

  /// Text style of the entered value, shared with fields built on
  /// [decoration] (e.g. dropdowns).
  static TextStyle textStyle(BuildContext context) =>
      TextStyle(color: context.color.textNatural, fontSize: 16);

  /// The field look, so other inputs can match it.
  static InputDecoration decoration(
    BuildContext context, {
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.color.textBody, fontSize: 16),
      filled: true,
      fillColor: context.color.inputFill,
      contentPadding: EdgeInsets.fromLTRB(
        prefixIcon == null ? 16 : 0,
        18,
        16,
        18,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                prefixIcon,
                size: 22,
                color: context.color.textNatural,
              ),
            ),
      prefixIconConstraints: const BoxConstraints(),
      suffixIcon: suffix,
      errorStyle: TextStyle(color: context.color.error),
      border: _border(context.color.inputBorder),
      enabledBorder: _border(context.color.inputBorder),
      focusedBorder: _border(context.color.primary),
      errorBorder: _border(context.color.error),
      focusedErrorBorder: _border(context.color.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      focusNode: focusNode,
      cursorColor: context.color.primary,
      style: textStyle(context),
      decoration: decoration(
        context,
        hint: hint,
        prefixIcon: prefixIcon,
        suffix: suffix,
      ),
    );
  }
}
