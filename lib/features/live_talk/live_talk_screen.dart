import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/ui/screens/widgets/app_plain_background.dart';
import 'package:aurenix/ui/screens/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/ui/screens/onboarding/widgets/wave_orb.dart';
import 'package:aurenix/ui/screens/live_talk/controllers/live_talk_controller.dart';

class LiveTalkScreen extends GetView<LiveTalkController> {
  const LiveTalkScreen({super.key});

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
          _CircleButton(
            icon: PhosphorIconsRegular.speakerHigh,
            onTap: controller.onAudioOutput,
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
    return Obx(() {
      final camera = controller.camera.value;
      if (camera != null) return _CameraCenter(controller, camera);
      if (controller.isSharingScreen.value) {
        return _ScreenShareCenter(controller: controller);
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WaveOrb(
              size: 196,
              showRing: false,
              showDots: true,
              speed: 2.5,
            ),
            const SizedBox(height: 28),
            Flexible(child: _Caption(controller: controller, showPrompt: true)),
            const SizedBox(height: 12),
            _Status(controller: controller),
          ],
        ),
      );
    });
  }
}

/// What the camera sees, filling the space above the caption.
class _CameraCenter extends StatelessWidget {
  const _CameraCenter(this.controller, this.camera);

  final LiveTalkController controller;
  final CameraController camera;

  @override
  Widget build(BuildContext context) {
    // The preview size is reported in landscape; the screen is portrait.
    final size = camera.value.previewSize;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox.expand(
                child: size == null
                    ? CameraPreview(camera)
                    : FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: size.height,
                          height: size.width,
                          child: CameraPreview(camera),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 96),
            child: _Caption(controller: controller, showPrompt: false),
          ),
          const SizedBox(height: 10),
          _Status(controller: controller),
        ],
      ),
    );
  }
}

/// Shown while the screen is shared: there is no preview of the screen
/// itself, so say what is happening and how to use it.
class _ScreenShareCenter extends StatelessWidget {
  const _ScreenShareCenter({required this.controller});

  final LiveTalkController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.color.tileFill,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.color.buttonHighlight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.color.primary,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.screencast,
                      size: 32,
                      color: context.color.textNatural,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomText(
                    'live_share_title'.tr,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                    color: context.color.textNatural,
                  ),
                  const SizedBox(height: 10),
                  CustomText(
                    (GetPlatform.isIOS
                            ? 'live_share_hint_ios'
                            : 'live_share_hint')
                        .tr,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                    color: context.color.textBody,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 96),
            child: _Caption(controller: controller, showPrompt: false),
          ),
          const SizedBox(height: 10),
          _Status(controller: controller),
        ],
      ),
    );
  }
}

/// What the user is saying, or the reply being read out.
class _Caption extends StatelessWidget {
  const _Caption({required this.controller, required this.showPrompt});

  final LiveTalkController controller;

  /// Show the "how can I help" prompt while there is no caption.
  final bool showPrompt;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final caption = controller.caption.value;
      if (!controller.showCaptions.value || caption.isEmpty) {
        if (!showPrompt) return const SizedBox.shrink();
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
    });
  }
}

/// Listening, thinking or muted, under the caption.
class _Status extends StatelessWidget {
  const _Status({required this.controller});

  final LiveTalkController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
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
            child: Obx(
              () => _PillButton(
                icon: PhosphorIconsRegular.camera,
                active: controller.camera.value != null,
                onTap: controller.onCamera,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => _PillButton(
                icon: PhosphorIconsRegular.screencast,
                active: controller.isSharingScreen.value,
                onTap: controller.onScreenShare,
              ),
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
  const _PillButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// Outlined, like the camera while it is on.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.color.tileFillHighlight,
      shape: StadiumBorder(
        side: active
            ? BorderSide(color: context.color.buttonHighlight)
            : BorderSide.none,
      ),
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
