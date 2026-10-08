import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';

/// Dark filled input with an optional leading icon, used on the form screens.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.hint,
    this.label,
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
    this.enabled = true,
    this.isPassword = false,
    this.reserveErrorSpace = false,
    this.focusNode,
  });

  /// Placeholder inside the field. Omit it where [label] already names the
  /// field, so the same words are not shown twice.
  final String? hint;

  /// Sits above the field and stays there once the user types, so the field
  /// keeps its name. Also what screen readers announce; without it they only
  /// get [hint], which disappears on the first keystroke.
  final String? label;

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

  /// Shows the value but refuses edits and never opens the keyboard. The
  /// field still looks active; pass [enabled] false for a field that is off.
  final bool readOnly;

  /// False dims the field and stops it taking focus, so it reads as off
  /// rather than merely uneditable.
  final bool enabled;

  /// Obscures the text and owns the show/hide toggle in the suffix, so each
  /// screen does not wire its own. Overrides [obscureText] and [suffix].
  final bool isPassword;

  /// Always lays out one blank line under the field, so showing an error does
  /// not change its height. Set it on fields that share a [Row] with another
  /// field, where one growing would move the other. Off elsewhere, because
  /// the blank line costs vertical space on every screen.
  final bool reserveErrorSpace;

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
      TextStyle(color: appColors.textNatural, fontSize: AppFontSize.body);

  /// How much a disabled field is faded.
  static const double _disabledOpacity = 0.45;

  /// The field look, so other inputs can match it.
  static InputDecoration decoration(
    BuildContext context, {
    String? hint,
    IconData? prefixIcon,
    Widget? suffix,
    bool enabled = true,
    bool reserveErrorSpace = false,
  }) {
    final color = appColors;
    final iconColor = enabled
        ? color.textNatural
        : color.textNatural.withValues(alpha: _disabledOpacity);
    return InputDecoration(
      enabled: enabled,
      hintText: hint,
      hintStyle: TextStyle(
        color: enabled
            ? color.textBody
            : color.textBody.withValues(alpha: _disabledOpacity),
        fontSize: AppFontSize.body,
      ),
      filled: true,
      fillColor: enabled
          ? color.inputFill
          : color.inputFill.withValues(alpha: _disabledOpacity),
      contentPadding: EdgeInsets.fromLTRB(
        prefixIcon == null ? 16 : 0,
        18,
        16,
        18,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
              child: Icon(prefixIcon, size: 22, color: iconColor),
            ),
      prefixIconConstraints: const BoxConstraints(),
      suffixIcon: suffix,
      // A blank helper line keeps the error message inside space the field
      // already occupies, so it does not grow when a validator fails.
      helperText: reserveErrorSpace ? ' ' : null,
      helperStyle: const TextStyle(fontSize: AppFontSize.overline, height: 1.2),
      errorStyle: TextStyle(
        color: color.error,
        fontSize: AppFontSize.overline,
        height: 1.2,
      ),
      errorMaxLines: 1,
      border: _border(color.inputBorder),
      enabledBorder: _border(color.inputBorder),
      disabledBorder: _border(
        color.inputBorder.withValues(alpha: _disabledOpacity),
      ),
      focusedBorder: _border(color.primary),
      errorBorder: _border(color.error),
      focusedErrorBorder: _border(color.error),
    );
  }

  static const double _labelGap = 8;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.isPassword || widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final field = _field(context);
    if (label == null) return field;
    final color = appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hidden from the semantics tree: the same text is attached to the
        // field below, so announcing it here as well would repeat it.
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppTextField._labelGap),
            child: AppText(
              label,
              maxLines: 1,
              fontSize: AppFontSize.caption,
              color: widget.enabled
                  ? color.textBody
                  : color.textBody.withValues(
                      alpha: AppTextField._disabledOpacity,
                    ),
            ),
          ),
        ),
        // The label is drawn outside the input, so there is nothing tying the
        // two together for a screen reader. Name the field explicitly.
        Semantics(label: label, child: field),
      ],
    );
  }

  Widget _field(BuildContext context) {
    final color = appColors;
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscured : widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      cursorColor: color.primary,
      style: widget.enabled
          ? AppTextField.textStyle(context)
          : AppTextField.textStyle(context).copyWith(
              color: color.textNatural.withValues(
                alpha: AppTextField._disabledOpacity,
              ),
            ),
      decoration: AppTextField.decoration(
        context,
        hint: widget.hint,
        prefixIcon: widget.isPassword
            ? (widget.prefixIcon ?? PhosphorIconsRegular.lockSimple)
            : widget.prefixIcon,
        suffix: widget.isPassword ? _visibilityToggle(context) : widget.suffix,
        enabled: widget.enabled,
        reserveErrorSpace: widget.reserveErrorSpace,
      ),
    );
  }

  Widget _visibilityToggle(BuildContext context) {
    return IconButton(
      onPressed: widget.enabled
          ? () => setState(() => _obscured = !_obscured)
          : null,
      tooltip: (_obscured ? 'password_show' : 'password_hide').tr,
      icon: Icon(
        _obscured ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
        size: 22,
        color: widget.enabled
            ? appColors.textNatural
            : appColors.textNatural.withValues(
                alpha: AppTextField._disabledOpacity,
              ),
      ),
    );
  }
}
