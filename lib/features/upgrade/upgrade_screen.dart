import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_fading_card.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/upgrade/controllers/upgrade_controller.dart';
import 'package:aurenix/features/upgrade/models/upgrade_plan.dart';
import 'package:aurenix/features/upgrade/widgets/upgrade_widgets.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class UpgradeScreen extends GetView<UpgradeController> {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = controller.plans;
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
      body: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UpgradeTopButton(
                icon: PhosphorIconsRegular.x,
                onTap: controller.onDismiss,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (_, i) => _PlanCard(
                    plan: plans[i],
                    onActivate: () => controller.onActivate(plans[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plan's name, what it includes and its price, with an Activate button.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onActivate});

  final UpgradePlan plan;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return AppFadingCard(
      fill: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            AppStrings.upgradeTo.trParams({'name': plan.nameKey.tr}),
            maxLines: 2,
            fontSize: AppFontSize.h2,
            fontWeight: FontWeight.w600,
            color: appColors.textNatural,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final key in plan.featureKeys) _FeatureRow(label: key.tr),
          const SizedBox(height: AppSpacing.lg),
          PlanPriceRow(
            plan: plan,
            action: AppButton(
              label: AppStrings.upgradeActivate.tr,
              onPressed: onActivate,
              height: 42,
              width: 136,
              fontSize: AppFontSize.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: appColors.tileFillHighlight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.check,
              size: 14,
              color: appColors.textNatural,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              label,
              maxLines: 1,
              fontSize: AppFontSize.label,
              color: appColors.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
