import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/chat_quota_service.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/upgrade/widgets/upgrade_widgets.dart';
import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// The body of the free-limit sheet: the plan, why the chat stopped and
/// when it opens again, and its price with an Activate button.
class ChatUpgradeDetails extends StatelessWidget {
  const ChatUpgradeDetails({
    super.key,
    this.plan = UpgradePlan.lite,
    this.onActivate,
  });

  final UpgradePlan plan;

  /// Replaces the default of opening the upgrade screen, e.g. to close a
  /// sheet on the way.
  final VoidCallback? onActivate;

  void _activate() => Get.toNamed(AppRoutes.upgrade);

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Column(
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
            onPressed: onActivate ?? _activate,
            height: 42,
            width: 136,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
