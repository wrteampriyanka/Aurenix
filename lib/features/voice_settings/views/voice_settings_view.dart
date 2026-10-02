import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_button.dart';
import '../../../commons/widgets/app_plain_background.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/widgets/wave_orb.dart';
import '../controllers/voice_settings_controller.dart';

class VoiceSettingsView extends GetView<VoiceSettingsController> {
  const VoiceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppPlainBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onClose: controller.onDismiss),
              Divider(height: 1, color: context.color.strokeDark),
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
                    const SizedBox(height: 12),
                    _Dots(controller: controller),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: AppButton(
                  label: 'voice_save'.tr,
                  icon: null,
                  height: 52,
                  fontSize: 16,
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
            color: context.color.tileFillHighlight,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onClose,
              child: SizedBox.square(
                dimension: 44,
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 20,
                  color: context.color.textNatural,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomText(
              'voice_title'.tr,
              maxLines: 1,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.color.textNatural,
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
        CustomText(
          'voice_greeting'.trParams({'name': voice.name}),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
          color: context.color.textNatural,
        ),
        const SizedBox(height: 6),
        CustomText(
          voice.taglineKey.tr,
          fontSize: 14,
          textAlign: TextAlign.center,
          color: context.color.textBody,
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
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == controller.index.value
                        ? context.color.textNatural
                        : context.color.platformIcon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
