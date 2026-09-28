import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/custom_text.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart';

/// A coloured tile at the top of the services sheet.
class _Service {
  const _Service({
    required this.labelKey,
    required this.color,
    this.svg,
    this.icon,
    this.action,
  });

  final String labelKey;
  final Color Function(AppColors) color;

  /// SVG asset, drawn white. Falls back to [icon] when null.
  final String? svg;
  final IconData? icon;

  /// Picked in the input when tapped; null just closes the sheet for now.
  final HomeAction? action;
}

/// An integrated app card under "Integrated Apps".
class _App {
  const _App({
    required this.nameKey,
    required this.descriptionKey,
    required this.logo,
  });

  final String nameKey;
  final String descriptionKey;
  final String logo;
}

/// Bottom sheet opened by the + in the home input.
class ServicesSheet extends GetView<HomeController> {
  const ServicesSheet({super.key});

  // TODO: attach a document and capture an image once pickers are added.
  static final _services = [
    _Service(
      labelKey: 'services_attach_document',
      svg: AppAssets.attachIcon,
      color: (c) => c.serviceAttach,
    ),
    _Service(
      labelKey: 'services_capture_image',
      icon: PhosphorIconsRegular.camera,
      color: (c) => c.serviceCapture,
    ),
    _Service(
      labelKey: 'services_generate_code',
      svg: AppAssets.codeIcon,
      color: (c) => c.serviceCode,
      action: HomeController.codeAction,
    ),
    _Service(
      labelKey: 'services_integration',
      svg: AppAssets.integrationIcon,
      color: (c) => c.serviceIntegration,
      action: HomeController.integrationAction,
    ),
    _Service(
      labelKey: 'services_ai_research',
      svg: AppAssets.researchIcon,
      color: (c) => c.serviceResearch,
      action: HomeController.researchAction,
    ),
    _Service(
      labelKey: 'services_generate_image',
      svg: AppAssets.generateImagesIcon,
      color: (c) => c.serviceGenerateImage,
      action: HomeController.generateImagesAction,
    ),
  ];

  static const _apps = [
    _App(
      nameKey: 'services_figma',
      descriptionKey: 'services_figma_desc',
      logo: AppAssets.figmaColorLogo,
    ),
    _App(
      nameKey: 'services_zync',
      descriptionKey: 'services_zync_desc',
      logo: AppAssets.zyncLogo,
    ),
    _App(
      nameKey: 'services_google_drive',
      descriptionKey: 'services_google_drive_desc',
      logo: AppAssets.googleDriveLogo,
    ),
  ];

  /// Parses the sheet's SVGs ahead of time so the first open doesn't
  /// spend its animation frames on them.
  static void precache() {
    final paths = {
      for (final service in _services) ?service.svg,
      for (final app in _apps)
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
                            onTap: () => controller.onService(service.action),
                          ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 12),
                        child: CustomText(
                          'services_integrated_apps'.tr,
                          fontSize: 12,
                          color: context.color.textBody,
                        ),
                      ),
                      // TODO: open the app once integrations are connected.
                      ..._pairs([
                        for (final app in _apps)
                          _AppCard(
                            app: app,
                            onTap: () => controller.onService(null),
                          ),
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

  final _App app;
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
                  app.logo.endsWith('.svg')
                      ? SvgPicture.asset(app.logo, width: 20, height: 20)
                      : Image.asset(app.logo, width: 20, height: 20),
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
