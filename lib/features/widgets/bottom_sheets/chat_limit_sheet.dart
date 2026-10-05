import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/home/widgets/chat_upgrade_card.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// Comes up over the chat once the free allowance is used up: the paid plan
/// up top, why the chat stopped and when it opens again, and its price with
/// a way through to the upgrade screen.
class ChatLimitSheet extends StatelessWidget {
  const ChatLimitSheet({super.key});

  /// Opens the sheet, unless another sheet or dialog is already up.
  static Future<void> show() {
    if ((Get.isBottomSheetOpen ?? false) || (Get.isDialogOpen ?? false)) {
      return Future.value();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const ChatLimitSheet(),
    );
  }

  void _activate() {
    Get.back();
    Get.toNamed(AppRoutes.upgrade);
  }

  @override
  Widget build(BuildContext context) {
    // Full width and flush with the bottom edge, rounded on top only, so it
    // rises out of the bottom of the screen as one smooth panel.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProHeader(),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: ChatUpgradeDetails(onActivate: _activate),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue banner with the "Aurenix Pro" wordmark, the sheet's handle on top.
///
/// Uses the app's shared top band (left → right deep blue, as on the auth
/// and home screens), painted over the card's own background so it darkens
/// into the details panel below instead of into the screen behind the card.
class _ProHeader extends StatelessWidget {
  const _ProHeader();

  /// Opacity of the band from the top of the header down.
  static const _fadeStops = [0.0, 0.3, 0.52, 0.68, 0.82, 0.92, 1.0];
  static const _fadeAlphas = [1.0, 0.98, 0.9, 0.72, 0.44, 0.18, 0.0];

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Container(
      height: 188,
      color: color.sheetBackground,
      child: Stack(
        children: [
          // The band itself, masked so it sinks into the panel colour.
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    for (final a in _fadeAlphas)
                      Colors.white.withValues(alpha: a),
                  ],
                  stops: _fadeStops,
                ).createShader(bounds),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: color.backgroundTopBand,
                      stops: const [0, 0.11, 0.26, 0.51, 0.72, 0.92, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  'Aurenix',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: color.textNatural,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.textNatural,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomText(
                    'Pro',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: color.backgroundTopBand.last,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
