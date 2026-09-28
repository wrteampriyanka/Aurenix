import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_plain_background.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/widgets/wave_orb.dart';
import '../controllers/live_talk_controller.dart';

class LiveTalkView extends GetView<LiveTalkController> {
  const LiveTalkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppPlainBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BottomGlow(),
            SafeArea(
              child: Column(
                children: [
                  _TopActions(controller: controller),
                  Divider(height: 1, color: context.color.strokeDark),
                  Expanded(child: _Center(controller: controller)),
                  _BottomActions(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Captions, speaker and voice settings, on the right.
class _TopActions extends StatelessWidget {
  const _TopActions({required this.controller});

  final LiveTalkController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(
            () => _CircleButton(
              icon: PhosphorIconsRegular.closedCaptioning,
              active: controller.showCaptions.value,
              onTap: controller.onToggleCaptions,
            ),
          ),
          const SizedBox(width: 14),
          Obx(
            () => _CircleButton(
              icon: controller.isSpeakerOn.value
                  ? PhosphorIconsRegular.speakerHigh
                  : PhosphorIconsRegular.speakerSlash,
              onTap: controller.onToggleSpeaker,
            ),
          ),
          const SizedBox(width: 14),
          _CircleButton(
            icon: PhosphorIconsRegular.slidersHorizontal,
            onTap: controller.onSettings,
          ),
        ],
      ),
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({required this.controller});

  final LiveTalkController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const WaveOrb(size: 196, showRing: false, showDots: true),
          const SizedBox(height: 28),
          Flexible(
            child: Obx(() {
              final caption = controller.caption.value;
              if (!controller.showCaptions.value || caption.isEmpty) {
                // Narrow like the design, so it wraps after "you".
                return SizedBox(
                  width: 250,
                  child: CustomText(
                    'home_prompt'.tr,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                    color: context.color.textNatural,
                  ),
                );
              }
              return SingleChildScrollView(
                reverse: true,
                child: CustomText(
                  caption,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                  color: context.color.textNatural,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Obx(
            () => CustomText(
              switch (controller.status.value) {
                _ when controller.isMuted.value => 'live_muted'.tr,
                LiveStatus.listening => 'live_listening'.tr,
                LiveStatus.thinking => 'live_thinking'.tr,
                LiveStatus.speaking || LiveStatus.idle => '',
              },
              fontSize: 14,
              color: context.color.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mic, camera, screen share and end, as four equal pills.
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});

  final LiveTalkController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _PillButton(
                icon: controller.isMuted.value
                    ? PhosphorIconsRegular.microphoneSlash
                    : PhosphorIconsRegular.microphone,
                onTap: controller.onToggleMic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PillButton(
              icon: PhosphorIconsRegular.camera,
              onTap: controller.onCamera,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PillButton(
              icon: PhosphorIconsRegular.screencast,
              onTap: controller.onScreenShare,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PillButton(
              icon: PhosphorIconsRegular.x,
              onTap: controller.onEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Filled blue, like captions being on in the design.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? context.color.primary : context.color.tileFillHighlight,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, size: 22, color: context.color.textNatural),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.tileFillHighlight,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Icon(icon, size: 22, color: context.color.textNatural),
        ),
      ),
    );
  }
}

/// Blue glow rising from the bottom edge behind the controls.
class _BottomGlow extends StatelessWidget {
  const _BottomGlow();

  @override
  Widget build(BuildContext context) {
    final glow = context.color.backgroundGlow;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 260,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 1.3),
              radius: 1.2,
              colors: [
                glow.withValues(alpha: 0.85),
                glow.withValues(alpha: 0.35),
                glow.withValues(alpha: 0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ),
    );
  }
}
