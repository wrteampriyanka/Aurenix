import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/chat_quota_service.dart';
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
/// Carries no fill of its own, only the outline, so it reads as part of the
/// conversation rather than a panel over it. The outline is closed on every
/// side, so the bottom edge stays visible.
class ChatUpgradeCard extends StatelessWidget {
  const ChatUpgradeCard({super.key, this.plan = UpgradePlan.lite});

  final UpgradePlan plan;

  /// Called once the user has paid: the allowance is lifted, which takes
  /// the card back out of the chat.
  static void markActivated() => ChatQuotaService.instance.activatePlan();

  void _activate() => Get.toNamed(AppRoutes.upgrade);

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return AppFadingCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      // No fill: the chat background shows through, leaving just the outline.
      fill: Colors.transparent,
      fade: CardFade.none,
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
          Obx(() {
            final resetsAt = ChatQuotaService.instance.resetsAt.value;
            return CustomText(
              resetsAt == null
                  ? 'chat_upgrade_limit'.tr
                  : 'chat_upgrade_limit_until'.trParams({
                      'time': TimeOfDay.fromDateTime(resetsAt).format(context),
                    }),
              maxLines: 3,
              fontSize: 13,
              color: color.textBody,
            );
          }),
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
