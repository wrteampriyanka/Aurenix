import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../widgets/custom_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/live_talk/controllers/live_talk_controller.dart';

/// Floating sheet opened by the speaker button, listing where the voice
/// can play: the phone speaker plus any connected headphones.
class AudioOutputSheet extends GetView<LiveTalkController> {
  const AudioOutputSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: context.color.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.color.tileBorder),
        ),
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
              child: Obx(
                () => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    children: _staggered(context, [
                      for (final device in controller.outputs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OutputTile(
                            device: device,
                            selected:
                                device.id == controller.selectedOutput.value,
                            onTap: () => controller.onSelectOutput(device),
                          ),
                        ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fades and slides [children] up one after another as the sheet opens,
  /// driven by the sheet's own route animation so closing plays it back.
  static List<Widget> _staggered(BuildContext context, List<Widget> children) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return children;
    const step = 0.1, span = 0.5;
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
}

class _OutputTile extends StatelessWidget {
  const _OutputTile({
    required this.device,
    required this.selected,
    required this.onTap,
  });

  final AudioOutput device;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: selected ? context.color.primary : context.color.tileBorder,
      ),
    );
    return Material(
      color: context.color.tileFill,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      device.isSpeaker ? 'live_output_speaker'.tr : device.name,
                      maxLines: 1,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.color.textNatural,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      device.isSpeaker
                          ? 'live_output_default'.tr
                          : 'live_output_connected'.tr,
                      fontSize: 13,
                      color: context.color.textBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? context.color.primary
                      : context.color.tileFillHighlight,
                ),
                child: Icon(
                  PhosphorIconsRegular.check,
                  size: 18,
                  color: selected
                      ? context.color.textNatural
                      : context.color.textBody,
                ),
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
