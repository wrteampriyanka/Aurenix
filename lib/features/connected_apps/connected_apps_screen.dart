import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_search_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/connected_apps/controllers/connected_apps_controller.dart';
import 'package:aurenix/features/connected_apps/widgets/integration_app_logo.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class ConnectedAppsScreen extends GetView<ConnectedAppsController> {
  const ConnectedAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: AppStrings.connectedAppsTitle.tr,
      header: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppSearchField(
          controller: controller.searchController,
          hintText: AppStrings.connectedAppsSearchHint.tr,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Obx(() {
        final connected = controller.connectedApps;
        final available = controller.availableApps;
        if (connected.isEmpty && available.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: AppText(
              AppStrings.connectedAppsEmpty.tr,
              fontSize: AppFontSize.label,
              textAlign: TextAlign.center,
              color: appColors.textBody,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (connected.isNotEmpty)
              _Section(
                titleKey: AppStrings.connectedAppsConnected,
                apps: connected,
                onTap: controller.onApp,
              ),
            if (connected.isNotEmpty && available.isNotEmpty)
              const SizedBox(height: AppSpacing.xxl),
            if (available.isNotEmpty)
              _Section(
                titleKey: AppStrings.connectedAppsMore,
                apps: available,
                onTap: controller.onApp,
              ),
          ],
        );
      }),
    );
  }
}

/// A section label over a two-column grid of app cards.
class _Section extends StatelessWidget {
  const _Section({
    required this.titleKey,
    required this.apps,
    required this.onTap,
  });

  final String titleKey;
  final List<IntegrationApp> apps;
  final ValueChanged<IntegrationApp> onTap;

  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          titleKey.tr,
          maxLines: 1,
          fontSize: AppFontSize.caption,
          color: appColors.textBody,
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < apps.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _gap),
          SizedBox(
            height: _AppCard.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _AppCard(app: apps[i], onTap: () => onTap(apps[i])),
                ),
                const SizedBox(width: _gap),
                Expanded(
                  child: i + 1 < apps.length
                      ? _AppCard(
                          app: apps[i + 1],
                          onTap: () => onTap(apps[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app, required this.onTap});

  final IntegrationApp app;
  final VoidCallback onTap;

  static const double _padding = 12;
  static const double _logoSize = 24;

  /// Padding around the logo row and two lines of description.
  static const double height = 64 + _padding * 2;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Material(
      color: color.sheetCard,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IntegrationAppLogo(app: app, size: _logoSize),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      app.nameKey.tr,
                      maxLines: 1,
                      fontSize: AppFontSize.label,
                      fontWeight: FontWeight.w500,
                      color: color.textNatural,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                app.descriptionKey.tr,
                maxLines: 2,
                fontSize: AppFontSize.overline,
                fontWeight: FontWeight.w400,
                color: color.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
