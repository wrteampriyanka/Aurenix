import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// On/off pill toggle: blue track with the thumb on the right when on,
/// grey track with the thumb on the left when off.
/// Pass `onChanged: null` to disable it.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 44,
    this.height = 26,
    this.activeColor,
    this.inactiveColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  /// Track colour when on. Defaults to the primary blue.
  final Color? activeColor;

  /// Track colour when off.
  final Color? inactiveColor;

  static const _duration = Duration(milliseconds: 200);
  static const double _padding = 3;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final thumbSize = height - _padding * 2;

    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: _duration,
            curve: Curves.easeOut,
            width: width,
            height: height,
            padding: const EdgeInsets.all(_padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: value
                  ? activeColor ?? context.color.primary
                  : inactiveColor ?? context.color.switchTrackOff,
            ),
            child: AnimatedAlign(
              duration: _duration,
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.switchThumb,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
