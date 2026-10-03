import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/ui/screens/widgets/custom_text.dart';

/// The app's one snackbar: a dark rounded card floating above the bottom
/// edge, in the same colours as the sheets and cards around it.
///
/// Use it everywhere instead of `Get.rawSnackbar`, which comes in with
/// Material's own blue-grey bar and square edges.
abstract final class AppSnackbar {
  /// Says something went through, e.g. "Copied".
  static void show(String message, {Duration? duration}) =>
      _show(message, duration: duration, isError: false);

  /// Says something failed or is not allowed; shown in the error colour.
  static void error(String message, {Duration? duration}) =>
      _show(message, duration: duration, isError: true);

  static const _duration = Duration(seconds: 2);

  static void _show(
    String message, {
    required bool isError,
    Duration? duration,
  }) {
    const color = AppColors.instance;
    final accent = isError ? color.error : color.buttonHighlight;
    // A second one replaces the first rather than queueing behind it.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.showSnackbar(
      GetSnackBar(
        messageText: CustomText(
          message,
          fontSize: 14,
          maxLines: 3,
          color: color.textNatural,
        ),
        icon: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(
            isError
                ? PhosphorIconsRegular.warningCircle
                : PhosphorIconsRegular.checkCircle,
            size: 20,
            color: accent,
          ),
        ),
        shouldIconPulse: false,
        backgroundColor: color.sheetCard,
        borderColor: isError ? accent.withValues(alpha: 0.5) : color.strokeDark,
        borderWidth: 1,
        borderRadius: 16,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        boxShadows: [
          BoxShadow(
            color: color.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        duration: duration ?? _duration,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
