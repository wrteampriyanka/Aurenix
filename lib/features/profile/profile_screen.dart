import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_fading_card.dart';
import 'package:aurenix/commons/widgets/app_top_bar.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/profile/controllers/profile_controller.dart';
import 'package:aurenix/features/profile/models/profile_menu_item.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
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
                    const SizedBox(height: AppSpacing.xxl),
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
                  color: appColors.primary,
                ),
                child: Icon(
                  PhosphorIconsRegular.user,
                  size: 22,
                  color: appColors.textNatural,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => AppText(
                        controller.userName.value,
                        maxLines: 1,
                        fontSize: AppFontSize.body,
                        fontWeight: FontWeight.w600,
                        color: appColors.textNatural,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => AppText(
                        controller.userEmail.value,
                        maxLines: 1,
                        fontSize: AppFontSize.caption,
                        color: appColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              GlassButton(
                icon: PhosphorIconsRegular.pencilSimpleLine,
                onTap: controller.onEditProfile,
                size: 40,
                iconSize: 18,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(height: 1, thickness: 1, color: appColors.profileCardDivider),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.profilePlanFree.tr,
                      maxLines: 1,
                      fontSize: AppFontSize.h2,
                      fontWeight: FontWeight.w700,
                      color: appColors.textNatural,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      AppStrings.profilePlanPrice.tr,
                      maxLines: 1,
                      fontSize: AppFontSize.caption,
                      color: appColors.textBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppButton(
                label: AppStrings.profileUpgradeNow.tr,
                icon: null,
                onPressed: controller.onUpgrade,
                height: 42,
                width: 136,
                fontSize: AppFontSize.label,
                color: appColors.upgradeButton,
                highlightColor: appColors.upgradeButtonHighlight,
                borderColor: appColors.upgradeButtonBorder,
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
        color: appColors.profileMenuCard,
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
                  color: appColors.profileCardDivider,
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
                        color: appColors.textNatural,
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        child: AppText(
                          items[i].labelKey.tr,
                          maxLines: 1,
                          fontSize: AppFontSize.chat,
                          color: appColors.textNatural,
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        size: 16,
                        color: appColors.textNatural,
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
