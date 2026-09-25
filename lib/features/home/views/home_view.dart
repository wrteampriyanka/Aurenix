import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_background.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/widgets/wave_orb.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundBase,
      body: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(controller: controller),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const WaveOrb(
                          size: 196,
                          showRing: false,
                          showDots: true,
                        ),
                        const SizedBox(height: 28),
                        // Narrow like the design, so it wraps after "you".
                        SizedBox(
                          width: 250,
                          child: CustomText(
                            'home_prompt'.tr,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            textAlign: TextAlign.center,
                            color: context.color.textBody,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final action in HomeController.actions)
                              _ActionChip(
                                action: action,
                                onTap: () => controller.onAction(action),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _InputBar(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _GlassButton(
            icon: PhosphorIconsRegular.sidebarSimple,
            onTap: controller.onMenu,
          ),
          Expanded(
            child: GestureDetector(
              onTap: controller.onModelTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CustomText(
                      'home_model_name'.tr,
                      maxLines: 1,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.color.textNatural,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 18,
                    color: context.color.textNatural,
                  ),
                ],
              ),
            ),
          ),
          _GlassPill(
            children: [
              _PillIcon(
                icon: PhosphorIconsRegular.chatCircleText,
                onTap: controller.onNewChat,
              ),
              SizedBox(
                height: 24,
                child: VerticalDivider(
                  width: 1,
                  color: context.color.tileBorder,
                ),
              ),
              _PillIcon(
                icon: PhosphorIconsRegular.dotsThree,
                onTap: controller.onMore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Frosted decoration shared by the top bar buttons.
BoxDecoration _glass(BuildContext context, BoxShape shape) => BoxDecoration(
  shape: shape,
  borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(24) : null,
  color: context.color.tileFillHighlight,
  border: Border.all(color: context.color.tileBorder),
);

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _glass(context, BoxShape.circle),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 48,
            child: Icon(icon, size: 22, color: context.color.textNatural),
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _glass(context, BoxShape.rectangle),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 44,
        height: 46,
        child: Icon(icon, size: 22, color: context.color.textNatural),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action, required this.onTap});

  final HomeAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.color.tileBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(action.icon, width: 18, height: 18),
              const SizedBox(width: 10),
              CustomText(
                action.labelKey.tr,
                fontSize: 15,
                color: context.color.textNatural,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: context.color.inputFill,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: context.color.inputBorder),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.onAttach,
                    icon: Icon(
                      PhosphorIconsRegular.plus,
                      size: 22,
                      color: context.color.textNatural,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      cursorColor: context.color.primary,
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                        color: context.color.textNatural,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'home_input_hint'.tr,
                        hintStyle: TextStyle(
                          color: context.color.textBody,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.onMic,
                    icon: Icon(
                      PhosphorIconsRegular.microphone,
                      size: 22,
                      color: context.color.textNatural,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _VoiceButton(onTap: controller.onVoice),
        ],
      ),
    );
  }
}

/// Round blue button with the same gradient as [AppButton].
class _VoiceButton extends StatelessWidget {
  const _VoiceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.color.buttonBorder),
        gradient: RadialGradient(
          center: const Alignment(-0.7, -1.4),
          radius: 1.6,
          colors: [context.color.buttonHighlight, context.color.primary],
          stops: const [0, 0.55],
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 52,
            child: Icon(
              PhosphorIconsRegular.waveform,
              size: 24,
              color: context.color.textNatural,
            ),
          ),
        ),
      ),
    );
  }
}
