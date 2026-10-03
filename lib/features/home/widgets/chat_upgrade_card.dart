import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/upgrade/widgets/upgrade_widgets.dart';
import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_fading_card.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// The card that drops into the conversation once the free plan runs out:
/// what the paid plan is called, why the chat stopped, and its price with a
/// way through to the upgrade screen.
///
/// Carries no fill of its own, only the fading outline, so it reads as part
/// of the conversation rather than a panel over it.
class ChatUpgradeCard extends StatelessWidget {
  const ChatUpgradeCard({super.key, this.plan = UpgradePlan.lite});

  final UpgradePlan plan;

  /// Set once the user has paid, which takes the card back out of the chat.
  /// Held for this app run only, until the purchase is a real one.
  static final isPlanActive = false.obs;

  static void markActivated() => isPlanActive.value = true;

  /// Lets a fresh run (or a sign-out) see the card again.
  @visibleForTesting
  static void reset() => isPlanActive.value = false;

  void _activate() => Get.toNamed(AppRoutes.upgrade);

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return AppFadingCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      // No fill: the chat background shows through, leaving just the outline.
      fill: Colors.transparent,
      fade: CardFade.rightward,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'upgrade_to'.trParams({'name': plan.nameKey.tr}),
            maxLines: 2,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color.textNatural,
          ),
          const SizedBox(height: 8),
          CustomText(
            'chat_upgrade_limit'.tr,
            maxLines: 3,
            fontSize: 13,
            color: color.textBody,
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: color.profileCardDivider),
          const SizedBox(height: 16),
          PlanPriceRow(
            plan: plan,
            action: AppButton(
              label: 'upgrade_activate'.tr,
              onPressed: _activate,
              height: 42,
              width: 136,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
