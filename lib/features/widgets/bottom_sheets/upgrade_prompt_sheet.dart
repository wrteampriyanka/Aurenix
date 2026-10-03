import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// The nudge that comes up over a chat once the user has been talking for a
/// while: what the paid plan adds, and a way through to the upgrade screen.
///
/// Only ever shown once per app run — [show] is a no-op after the first
/// time, so a long session is not interrupted twice.
class UpgradePromptSheet extends StatelessWidget {
  const UpgradePromptSheet({super.key});

  /// The plan the nudge advertises.
  static const plan = UpgradePlan.pro;

  static bool _shown = false;

  /// Whether the nudge still has to be shown this run.
  static bool get isPending => !_shown;

  static Future<void> show() {
    if (_shown) return Future.value();
    _shown = true;
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
      builder: (_) => const UpgradePromptSheet(),
    );
  }

  /// Lets a fresh install (or a sign-out) see the nudge again.
  @visibleForTesting
  static void reset() => _shown = false;

  void _upgrade() {
    Get.back();
    Get.toNamed(AppRoutes.upgrade);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: color.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.tileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: color.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.tileFillHighlight,
                        shape: BoxShape.circle,
                        border: Border.all(color: color.tileBorder),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.lightning,
                        size: 26,
                        color: color.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'upgrade_prompt_title'.tr,
                    maxLines: 2,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                    color: color.textNatural,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    'upgrade_prompt_desc'.tr,
                    maxLines: 3,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                    color: color.textBody,
                  ),
                  const SizedBox(height: 16),
                  for (final key in plan.featureKeys)
                    _FeatureRow(label: key.tr),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'upgrade_prompt_action'.tr,
                    icon: null,
                    height: 54,
                    fontSize: 17,
                    onPressed: _upgrade,
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: Get.back,
                    child: CustomText(
                      'upgrade_prompt_later'.tr,
                      fontSize: 15,
                      color: color.textBody,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of what the plan adds, ticked off.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.color.tileFillHighlight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.check,
              size: 13,
              color: context.color.textNatural,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              label,
              maxLines: 2,
              fontSize: 14,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
