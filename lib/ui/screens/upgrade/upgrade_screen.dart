import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_fading_card.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import 'controllers/upgrade_controller.dart';
import 'models/upgrade_plan.dart';
import 'widgets/upgrade_widgets.dart';

class UpgradeScreen extends GetView<UpgradeController> {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = controller.plans;
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
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
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            'upgrade_to'.trParams({'name': plan.nameKey.tr}),
            maxLines: 2,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.color.textNatural,
          ),
          const SizedBox(height: 16),
          for (final key in plan.featureKeys) _FeatureRow(label: key.tr),
          const SizedBox(height: 16),
          PlanPriceRow(
            plan: plan,
            action: AppButton(
              label: 'upgrade_activate'.tr,
              onPressed: onActivate,
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
              color: context.color.tileFillHighlight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.check,
              size: 14,
              color: context.color.textNatural,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CustomText(
              label,
              maxLines: 1,
              fontSize: 14,
              color: context.color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}
