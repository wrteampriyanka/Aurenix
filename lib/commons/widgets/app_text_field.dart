import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Dark filled input with a leading icon, used on the auth screens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    this.controller,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String hint;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  static const double _radius = 14;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_radius),
    borderSide: BorderSide(color: color),
  );

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
      cursorColor: context.color.primary,
      style: TextStyle(color: context.color.textNatural, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.color.textBody, fontSize: 16),
        filled: true,
        fillColor: context.color.inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(prefixIcon, size: 22, color: context.color.textNatural),
        ),
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffix,
        errorStyle: TextStyle(color: context.color.error),
        border: _border(context.color.inputBorder),
        enabledBorder: _border(context.color.inputBorder),
        focusedBorder: _border(context.color.primary),
        errorBorder: _border(context.color.error),
        focusedErrorBorder: _border(context.color.error),
      ),
    );
  }
}
