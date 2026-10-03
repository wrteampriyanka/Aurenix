import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/ui/screens/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/ui/screens/upgrade/models/upgrade_plan.dart';

/// Round frosted button at the top left of the upgrade screens (close/back).
class UpgradeTopButton extends StatelessWidget {
  const UpgradeTopButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Material(
          color: context.color.tileFillHighlight,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox.square(
              dimension: 44,
              child: Icon(icon, size: 20, color: context.color.textNatural),
            ),
          ),
        ),
      ),
    );
  }
}

/// The plan's trial price and renewal price, with an action on the right.
class PlanPriceRow extends StatelessWidget {
  const PlanPriceRow({super.key, required this.plan, required this.action});

  final UpgradePlan plan;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                plan.priceKey.tr,
                maxLines: 1,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.color.textNatural,
              ),
              const SizedBox(height: 2),
              CustomText(
                plan.renewalKey.tr,
                maxLines: 1,
                fontSize: 13,
                color: context.color.textBody,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        action,
      ],
    );
  }
}
