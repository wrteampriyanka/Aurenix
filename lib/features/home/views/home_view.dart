import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/app_background.dart';
import '../../../commons/widgets/custom_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/widgets/wave_orb.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/chat_messages.dart';
import '../widgets/sidebar_drawer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: context.color.sidebarBackground,
      body: SidebarDrawer(
        animation: controller.drawer,
        sidebar: const AppSidebar(),
        child: _HomeBody(controller: controller),
      ),
    );
    // Back closes the drawer first.
    return Obx(
      () => PopScope(
        canPop: !controller.isDrawerOpen.value,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.closeDrawer();
        },
        child: scaffold,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.color.backgroundBase,
      child: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(controller: controller),
              Expanded(
                child: Obx(
                  () => controller.messages.isEmpty
                      ? _Welcome(controller: controller)
                      : ChatMessages(controller: controller),
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

class _Welcome extends StatelessWidget {
  const _Welcome({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const WaveOrb(size: 196, showRing: false, showDots: true),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
              decoration: BoxDecoration(
                color: context.color.inputFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.color.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: controller.messageController,
                      cursorColor: context.color.primary,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.onSend(),
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: controller.onAttach,
                        icon: Icon(
                          PhosphorIconsRegular.plus,
                          size: 22,
                          color: context.color.textNatural,
                        ),
                      ),
                      Obx(() {
                        final action = controller.selectedAction.value;
                        return action == null
                            ? const SizedBox.shrink()
                            : _ActionTag(
                                action: action,
                                onClear: controller.onClearAction,
                              );
                      }),
                      const Spacer(),
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => controller.isGenerating.value
                ? _RoundButton(
                    icon: PhosphorIconsFill.pause,
                    onTap: controller.onStop,
                  )
                : controller.hasText.value
                ? _RoundButton(
                    icon: PhosphorIconsRegular.arrowUp,
                    onTap: controller.onSend,
                  )
                : _RoundButton(
                    icon: PhosphorIconsRegular.waveform,
                    onTap: controller.onVoice,
                  ),
          ),
        ],
      ),
    );
  }
}

/// The chip picked on the welcome screen, e.g. "Research", with a remove x.
class _ActionTag extends StatelessWidget {
  const _ActionTag({required this.action, required this.onClear});

  final HomeAction action;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.tileBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(action.icon, width: 16, height: 16),
          const SizedBox(width: 8),
          CustomText(
            action.labelKey.tr,
            fontSize: 13,
            color: context.color.textNatural,
          ),
          InkResponse(
            onTap: onClear,
            radius: 14,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                PhosphorIconsRegular.x,
                size: 14,
                color: context.color.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round blue button with the same gradient as [AppButton].
class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
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
            child: Icon(icon, size: 24, color: context.color.textNatural),
          ),
        ),
      ),
    );
  }
}
