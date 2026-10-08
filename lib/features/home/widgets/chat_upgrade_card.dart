import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/chat_quota_service.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/upgrade/widgets/upgrade_widgets.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

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
    final color = appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.upgradeTo.trParams({'name': plan.nameKey.tr}),
          maxLines: 2,
          fontSize: AppFontSize.h3,
          fontWeight: FontWeight.w700,
          color: color.textNatural,
        ),
        const SizedBox(height: AppSpacing.sm),
        Obx(() {
          final resetsAt = ChatQuotaService.instance.resetsAt.value;
          return AppText(
            resetsAt == null
                ? AppStrings.chatUpgradeLimit.tr
                : AppStrings.chatUpgradeLimitUntil.trParams({
                    'time': TimeOfDay.fromDateTime(resetsAt).format(context),
                  }),
            maxLines: 3,
            fontSize: AppFontSize.caption,
            color: color.textBody,
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, thickness: 1, color: color.profileCardDivider),
        const SizedBox(height: AppSpacing.lg),
        PlanPriceRow(
          plan: plan,
          action: AppButton(
            label: AppStrings.upgradeActivate.tr,
            onPressed: onActivate ?? _activate,
            height: 42,
            width: 136,
            fontSize: AppFontSize.label,
          ),
        ),
      ],
    );
  }
}
