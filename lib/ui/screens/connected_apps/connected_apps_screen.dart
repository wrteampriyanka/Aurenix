import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_plain_background.dart';
import '../widgets/app_search_field.dart';
import '../widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/connected_apps/controllers/connected_apps_controller.dart';
import 'widgets/integration_app_logo.dart';

class ConnectedAppsScreen extends GetView<ConnectedAppsController> {
  const ConnectedAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDetailPage(
      title: 'connected_apps_title'.tr,
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: AppSearchField(
          controller: controller.searchController,
          hintText: 'connected_apps_search_hint'.tr,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Obx(() {
        final connected = controller.connectedApps;
        final available = controller.availableApps;
        if (connected.isEmpty && available.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CustomText(
              'connected_apps_empty'.tr,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: context.color.textBody,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (connected.isNotEmpty)
              _Section(
                titleKey: 'connected_apps_connected',
                apps: connected,
                onTap: controller.onApp,
              ),
            if (connected.isNotEmpty && available.isNotEmpty)
              const SizedBox(height: 24),
            if (available.isNotEmpty)
              _Section(
                titleKey: 'connected_apps_more',
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
        CustomText(
          titleKey.tr,
          maxLines: 1,
          fontSize: 13,
          color: context.color.textBody,
        ),
        const SizedBox(height: 12),
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
    final color = context.color;
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      app.nameKey.tr,
                      maxLines: 1,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color.textNatural,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomText(
                app.descriptionKey.tr,
                maxLines: 2,
                fontSize: 12,
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
