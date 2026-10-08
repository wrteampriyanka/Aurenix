import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';

/// Rounded search pill with a magnifier, and a clear button that shows up
/// once something is typed.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: color.inputFill,
        borderRadius: BorderRadius.circular(_height / 2),
        border: Border.all(color: color.inputBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 22,
            color: color.textNatural,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              cursorColor: color.primary,
              style: TextStyle(
                color: color.textNatural,
                fontSize: AppFontSize.chat,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: color.textBody,
                  fontSize: AppFontSize.chat,
                ),
                hintMaxLines: 1,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox(width: 14)
                : InkResponse(
                    onTap: controller.clear,
                    radius: 18,
                    child: SizedBox(
                      width: 40,
                      height: _height,
                      child: Icon(
                        PhosphorIconsFill.xCircle,
                        size: 18,
                        color: color.textBody,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
