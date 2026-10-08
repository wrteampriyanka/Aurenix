import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/live_talk/controllers/live_talk_controller.dart';
import 'package:aurenix/features/live_talk/models/audio_output.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/sheet_reveal.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

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
          color: appColors.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: appColors.tileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: appColors.sheetHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: Obx(
                () => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    children: staggeredSheetRows(context, [
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
        color: selected ? appColors.primary : appColors.tileBorder,
      ),
    );
    return Material(
      color: appColors.tileFill,
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
                    AppText(
                      device.isSpeaker
                          ? AppStrings.liveOutputSpeaker.tr
                          : device.name,
                      maxLines: 1,
                      fontSize: AppFontSize.body,
                      fontWeight: FontWeight.w600,
                      color: appColors.textNatural,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      device.isSpeaker
                          ? AppStrings.liveOutputDefault.tr
                          : AppStrings.liveOutputConnected.tr,
                      fontSize: AppFontSize.caption,
                      color: appColors.textBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? appColors.primary
                      : appColors.tileFillHighlight,
                ),
                child: Icon(
                  PhosphorIconsRegular.check,
                  size: 18,
                  color: selected ? appColors.textNatural : appColors.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
