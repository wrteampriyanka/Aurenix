import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_plain_background.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/services/voice_service.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/onboarding/widgets/wave_orb.dart';
import 'package:aurenix/features/voice_settings/controllers/voice_settings_controller.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class VoiceSettingsScreen extends GetView<VoiceSettingsController> {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundBase,
      body: AppPlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onClose: controller.onDismiss),
              Divider(height: 1, color: appColors.strokeDark),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.onOrb,
                      child: Obx(
                        () => AnimatedScale(
                          scale: controller.isSpeaking.value ? 1.06 : 1,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                          child: const WaveOrb(
                            size: 196,
                            showRing: false,
                            showDots: true,
                            speed: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 64,
                      child: PageView.builder(
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: controller.voices.length,
                        itemBuilder: (_, i) =>
                            _VoiceName(voice: controller.voices[i]),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Dots(controller: controller),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: AppButton(
                  label: AppStrings.voiceSave.tr,
                  icon: null,
                  height: 52,
                  fontSize: AppFontSize.body,
                  onPressed: controller.onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Close button and title, like the design's sheet header.
class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Material(
            color: appColors.tileFillHighlight,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onClose,
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 20,
                  color: appColors.textNatural,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: AppText(
              AppStrings.voiceTitle.tr,
              maxLines: 1,
              fontSize: AppFontSize.h1,
              fontWeight: FontWeight.w600,
              color: appColors.textNatural,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceName extends StatelessWidget {
  const _VoiceName({required this.voice});

  final AssistantVoice voice;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          AppStrings.voiceGreeting.trParams({'name': voice.name}),
          fontSize: AppFontSize.h1,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: appColors.textNatural,
        ),
        const SizedBox(height: 6),
        AppText(
          voice.taglineKey.tr,
          fontSize: AppFontSize.label,
          textAlign: TextAlign.center,
          color: appColors.textBody,
        ),
      ],
    );
  }
}

/// Which voice is on screen; tap one to jump to it.
class _Dots extends StatelessWidget {
  const _Dots({required this.controller});

  final VoiceSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < controller.voices.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.onDot(i),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == controller.index.value
                        ? appColors.textNatural
                        : appColors.platformIcon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
