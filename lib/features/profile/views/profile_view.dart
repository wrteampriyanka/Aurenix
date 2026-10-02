import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_background.dart';
import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_fading_card.dart';
import '../../../commons/widgets/app_top_bar.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                onMenu: controller.onBack,
                onModelTap: controller.onModelTap,
                onNewChat: controller.onNewChat,
                onMore: controller.onMore,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    _ProfileCard(controller: controller),
                    const SizedBox(height: 14),
                    _MenuCard(
                      items: ProfileController.settingsItems,
                      onTap: controller.onItem,
                    ),
                    const SizedBox(height: 24),
                    _MenuCard(
                      items: ProfileController.accountItems,
                      onTap: controller.onItem,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// User details and current plan, on a card that fades to dark.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return AppFadingCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.color.primary,
                ),
                child: Icon(
                  PhosphorIconsRegular.user,
                  size: 22,
                  color: context.color.textNatural,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => CustomText(
                        controller.userName.value,
                        maxLines: 1,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.color.textNatural,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => CustomText(
                        controller.userEmail.value,
                        maxLines: 1,
                        fontSize: 13,
                        color: context.color.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              GlassButton(
                icon: PhosphorIconsRegular.pencilSimple,
                onTap: controller.onEditProfile,
                size: 40,
                iconSize: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: context.color.profileCardDivider,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'profile_plan_free'.tr,
                      maxLines: 1,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.color.textNatural,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      'profile_plan_price'.tr,
                      maxLines: 1,
                      fontSize: 13,
                      color: context.color.textBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: 'profile_upgrade_now'.tr,
                icon: null,
                onPressed: controller.onUpgrade,
                height: 42,
                width: 136,
                fontSize: 14,
                color: context.color.upgradeButton,
                highlightColor: context.color.upgradeButtonHighlight,
                borderColor: context.color.upgradeButtonBorder,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items, required this.onTap});

  final List<ProfileMenuItem> items;
  final ValueChanged<ProfileMenuItem> onTap;

  static const _rowHeight = 64.0;
  static const _horizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.profileMenuCard,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: _horizontalPadding,
                  endIndent: _horizontalPadding,
                  color: context.color.profileCardDivider,
                ),
              InkWell(
                onTap: () => onTap(items[i]),
                child: Container(
                  height: _rowHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        items[i].icon,
                        size: 22,
                        color: context.color.textNatural,
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: CustomText(
                          items[i].labelKey.tr,
                          maxLines: 1,
                          fontSize: 15,
                          color: context.color.textNatural,
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: context.color.textNatural,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
