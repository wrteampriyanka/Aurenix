import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/ui/screens/widgets/app_button.dart';
import 'package:aurenix/ui/screens/widgets/custom_text.dart';

/// Floating sheet describing a third-party app: its logo, name and handle,
/// a Connect or Disconnect button, and the permissions it grants.
///
/// Open it with [AppInfoSheet.show]. The header, button and each permission
/// row fade and slide up one after another as the sheet opens.
class AppInfoSheet extends StatelessWidget {
  const AppInfoSheet({
    super.key,
    required this.logo,
    required this.name,
    required this.handle,
    required this.permissions,
    required this.connected,
    required this.onConnect,
    required this.onDisconnect,
  });

  final Widget logo;
  final String name;

  /// Account or API the app is reached through, e.g. `@figma-automation-api`.
  final String handle;

  /// One line per permission, already translated.
  final List<String> permissions;

  /// Shows Disconnect when true, Connect otherwise.
  final bool connected;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  static Future<void> show({
    required Widget logo,
    required String name,
    required String handle,
    required List<String> permissions,
    required bool connected,
    required VoidCallback onConnect,
    required VoidCallback onDisconnect,
  }) {
    return showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 450),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => AppInfoSheet(
        logo: logo,
        name: name,
        handle: handle,
        permissions: permissions,
        connected: connected,
        onConnect: onConnect,
        onDisconnect: onDisconnect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    final reveal = _Stagger(ModalRoute.of(context)?.animation);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: color.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.tileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: color.sheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.tileBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          reveal(
                            0,
                            _Header(logo: logo, name: name, handle: handle),
                          ),
                          const SizedBox(height: 16),
                          reveal(
                            1,
                            connected
                                ? _DisconnectButton(onPressed: onDisconnect)
                                : AppButton(
                                    label: 'app_info_connect'.tr,
                                    icon: null,
                                    height: 44,
                                    fontSize: 15,
                                    onPressed: onConnect,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    if (permissions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.sheetCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < permissions.length; i++)
                              reveal(i + 2, _PermissionRow(permissions[i])),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.logo, required this.name, required this.handle});

  final Widget logo;
  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.sheetCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: logo,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                name,
                maxLines: 1,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color.textNatural,
              ),
              const SizedBox(height: 4),
              CustomText(
                handle,
                maxLines: 1,
                fontSize: 12,
                showUnderline: true,
                underlineOrLineColor: color.textBody,
                color: color.textBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisconnectButton extends StatelessWidget {
  const _DisconnectButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.sheetCard,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 44,
          child: Center(
            child: CustomText(
              'app_info_disconnect'.tr,
              maxLines: 1,
              fontSize: 15,
              color: context.color.textBody,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.tileFillHighlight,
            ),
            child: Icon(
              PhosphorIconsRegular.check,
              size: 14,
              color: color.textBody,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              label,
              maxLines: 2,
              fontSize: 14,
              color: color.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps the i-th child in a fade and slide up that starts a little after
/// the previous one, driven by the sheet's route animation so closing plays
/// it back.
class _Stagger {
  const _Stagger(this.animation);

  final Animation<double>? animation;

  static const double _start = 0.15, _step = 0.08, _span = 0.5;

  Widget call(int index, Widget child) {
    final animation = this.animation;
    if (animation == null) return child;
    final begin = (_start + index * _step).clamp(0.0, 1 - _span);
    final progress = animation.drive(
      CurveTween(
        curve: Interval(begin, begin + _span, curve: Curves.easeOutCubic),
      ),
    );
    return FadeTransition(
      opacity: progress,
      child: SlideTransition(
        position: progress.drive(
          Tween(begin: const Offset(0, 0.3), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
