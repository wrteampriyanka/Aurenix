import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../custom_text.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../connected_apps/services/connected_apps_service.dart';
import '../../connected_apps/widgets/integration_app_logo.dart';
import '../../home/controllers/home_controller.dart';

/// A coloured tile at the top of the services sheet.
class _Service {
  const _Service({
    required this.labelKey,
    required this.color,
    required this.onTap,
    this.svg,
    this.icon,
  });

  final String labelKey;
  final Color Function(AppColors) color;

  /// SVG asset, drawn white. Falls back to [icon] when null.
  final String? svg;
  final IconData? icon;

  /// What the tile does; each one closes the sheet first.
  final void Function(HomeController) onTap;
}

/// Bottom sheet opened by the + in the home input.
class ServicesSheet extends GetView<HomeController> {
  const ServicesSheet({super.key});

  static final _services = [
    _Service(
      labelKey: 'services_attach_document',
      svg: AppAssets.attachIcon,
      color: (c) => c.serviceAttach,
      onTap: (c) => c.onAttachDocument(),
    ),
    _Service(
      labelKey: 'services_capture_image',
      icon: PhosphorIconsRegular.camera,
      color: (c) => c.serviceCapture,
      onTap: (c) => c.onCaptureImage(),
    ),
    _Service(
      labelKey: 'services_generate_code',
      svg: AppAssets.codeIcon,
      color: (c) => c.serviceCode,
      onTap: (c) => c.onService(HomeController.codeAction),
    ),
    _Service(
      labelKey: 'services_integration',
      svg: AppAssets.integrationIcon,
      color: (c) => c.serviceIntegration,
      onTap: (c) => c.onIntegrations(),
    ),
    _Service(
      labelKey: 'services_ai_research',
      svg: AppAssets.researchIcon,
      color: (c) => c.serviceResearch,
      onTap: (c) => c.onService(HomeController.researchAction),
    ),
    _Service(
      labelKey: 'services_generate_image',
      svg: AppAssets.generateImagesIcon,
      color: (c) => c.serviceGenerateImage,
      onTap: (c) => c.onService(HomeController.generateImagesAction),
    ),
  ];

  /// Parses the sheet's SVGs ahead of time so the first open doesn't
  /// spend its animation frames on them.
  static void precache() {
    final paths = {
      for (final service in _services) ?service.svg,
      for (final app in ConnectedAppsService.apps)
        if (app.logo.endsWith('.svg')) app.logo,
    };
    for (final path in paths) {
      final loader = SvgAssetLoader(path);
      svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apps = ConnectedAppsService.to.connectedApps;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.color.sheetBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: context.color.tileBorder),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.color.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _staggered(context, [
                      ..._pairs([
                        for (final service in _services)
                          _ServiceTile(
                            service: service,
                            onTap: () => service.onTap(controller),
                          ),
                      ]),
                      if (apps.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                          child: CustomText(
                            'services_integrated_apps'.tr,
                            fontSize: 12,
                            color: context.color.textBody,
                          ),
                        ),
                      ..._pairs([
                        for (final app in apps)
                          _AppCard(app: app, onTap: controller.onIntegrations),
                      ]),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fades and slides [children] up one after another as the sheet opens,
  /// driven by the sheet's own route animation so closing plays it back.
  static List<Widget> _staggered(BuildContext context, List<Widget> children) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return children;
    const step = 0.08, span = 0.5;
    return [
      for (var i = 0; i < children.length; i++)
        _Reveal(
          animation: animation.drive(
            CurveTween(
              curve: Interval(
                (0.15 + i * step).clamp(0.0, 1 - span),
                (0.15 + i * step + span).clamp(span, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          child: children[i],
        ),
    ];
  }

  /// Lays [children] out two per row, leaving a gap for an odd last one.
  static List<Widget> _pairs(List<Widget> children) => [
    for (var i = 0; i < children.length; i += 2)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
  ];
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onTap});

  final _Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final white = context.color.textOnPrimary;
    return Material(
      color: service.color(context.color),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.svg case final svg?)
                SvgPicture.asset(
                  svg,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(white, BlendMode.srcIn),
                )
              else
                Icon(service.icon, size: 18, color: white),
              const SizedBox(height: 6),
              CustomText(
                service.labelKey.tr,
                maxLines: 1,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app, required this.onTap});

  final IntegrationApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.sheetCard,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IntegrationAppLogo(app: app, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomText(
                      app.nameKey.tr,
                      maxLines: 1,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.color.textNatural,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomText(
                app.descriptionKey.tr,
                maxLines: 2,
                fontSize: 12,
                color: context.color.textBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  /// 0 hidden, 1 in place.
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(0, 0.3), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
