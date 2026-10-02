import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'custom_text.dart';

/// Row of [length] boxes for entering a numeric verification code.
///
/// A single hidden [TextField] holds the code, so typing, backspace, paste
/// and SMS/email one-time-code autofill all work as in a normal field; the
/// boxes only render its value and highlight the next digit to enter.
class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    required this.controller,
    this.focusNode,
    this.length = 4,
    this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  static const double _boxHeight = 48;
  static const double _gap = 14;
  static const double _radius = 10;

  late FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AppOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onChanged);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _boxHeight,
      child: Stack(
        children: [
          // Invisible input underneath: receives taps, keyboard and autofill.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.length == widget.length) {
                    widget.onCompleted?.call(value);
                  }
                },
              ),
            ),
          ),
          IgnorePointer(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                final code = value.text;
                final active = code.length.clamp(0, widget.length - 1);
                return Row(
                  children: [
                    for (var i = 0; i < widget.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      Expanded(
                        child: _OtpBox(
                          digit: i < code.length ? code[i] : null,
                          active: _focusNode.hasFocus && i == active,
                          radius: _radius,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.active,
    required this.radius,
  });

  /// Entered digit, or null to show the dimmed placeholder.
  final String? digit;
  final bool active;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? context.color.backgroundBase : context.color.inputFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: active ? context.color.primary : context.color.inputBorder,
        ),
      ),
      child: CustomText(
        digit ?? '0',
        fontSize: 16,
        color: digit != null
            ? context.color.textNatural
            : context.color.textBody,
      ),
    );
  }
}
