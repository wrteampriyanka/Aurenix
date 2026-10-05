import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/widgets/app_background.dart';
import 'package:aurenix/features/widgets/app_top_bar.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/onboarding/widgets/wave_orb.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';
import 'package:aurenix/features/presets/widgets/preset_widgets.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/features/home/widgets/app_sidebar.dart';
import 'package:aurenix/features/home/widgets/chat_messages.dart';
import 'package:aurenix/features/home/widgets/sidebar_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebar = Get.find<SidebarController>();
    final scaffold = Scaffold(
      backgroundColor: context.color.sidebarBackground,
      body: SidebarDrawer(
        animation: controller.drawer,
        expand: sidebar.search,
        sidebar: const AppSidebar(),
        child: _HomeBody(controller: controller),
      ),
    );
    // Back leaves search, then closes the drawer.
    return Obx(
      () => PopScope(
        canPop: !controller.isDrawerOpen.value,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          sidebar.isSearching.value
              ? sidebar.onSearchBack()
              : controller.closeDrawer();
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
              Obx(
                () => AppTopBar(
                  onMenu: controller.onMenu,
                  onModelTap: controller.onModelTap,
                  onNewChat: controller.onNewChat,
                  onMore: controller.onMore,
                  trailing: switch (controller.preset.value) {
                    final preset? => PresetAvatar(
                      image: preset.image,
                      size: 30,
                    ),
                    null => null,
                  },
                ),
              ),
              Obx(() {
                if (controller.preset.value == null ||
                    !controller.showPresetNotice.value) {
                  return const SizedBox.shrink();
                }
                return ChatNotice(
                  text: 'preset_chat_notice'.tr,
                  onClose: controller.onClosePresetNotice,
                );
              }),
              Expanded(
                child: Obx(() {
                  if (controller.messages.isNotEmpty) {
                    return ChatMessages(controller: controller);
                  }
                  return switch (controller.preset.value) {
                    final preset? => _PresetWelcome(
                      preset: preset,
                      onVisitSite: controller.onVisitPresetSite,
                    ),
                    null => _Welcome(controller: controller),
                  };
                }),
              ),
              Obx(() {
                final preset = controller.preset.value;
                if (preset == null || controller.messages.isNotEmpty) {
                  return const SizedBox.shrink();
                }
                return _QuickStarters(
                  starters: preset.quickStarters,
                  onTap: controller.onQuickStarter,
                );
              }),
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

/// Empty state of a preset chat: the preset's avatar in a glow, its name
/// and description, and a link to its site.
class _PresetWelcome extends StatelessWidget {
  const _PresetWelcome({required this.preset, required this.onVisitSite});

  final Preset preset;
  final VoidCallback onVisitSite;

  static const double _avatar = 84;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(
              width: _avatar * 2.2,
              height: _avatar * 2.2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.accentPurple.withValues(alpha: 0.45),
                          color.accentPurple.withValues(alpha: 0),
                        ],
                        stops: const [0.2, 1],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                  PresetAvatar(image: preset.image, size: _avatar),
                ],
              ),
            ),
            const SizedBox(height: 4),
            CustomText(
              preset.name,
              maxLines: 2,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
              color: color.textNatural,
            ),
            const SizedBox(height: 8),
            CustomText(
              preset.description,
              maxLines: 3,
              fontSize: 14,
              textAlign: TextAlign.center,
              color: color.textBody,
            ),
            const SizedBox(height: 18),
            PresetVisitSiteButton(onTap: onVisitSite),
          ],
        ),
      ),
    );
  }
}

/// "Quick Starters" and the preset's prompt chips, just above the input.
class _QuickStarters extends StatelessWidget {
  const _QuickStarters({required this.starters, required this.onTap});

  final List<String> starters;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: PresetSectionTitle('presets_quick_starters'.tr),
        ),
        PresetQuickStarters(starters: starters, onTap: onTap),
      ],
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
                  Obx(() {
                    final file = controller.attachment.value;
                    if (file == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: _AttachmentChip(
                        attachment: file,
                        onRemove: controller.onRemoveAttachment,
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Obx(
                      () => TextField(
                        controller: controller.messageController,
                        focusNode: controller.messageFocus,
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
                          hintText: controller.isListening.value
                              ? 'chat_listening_hint'.tr
                              : controller.isChatLimited
                              ? 'chat_limit_hint'.tr
                              : 'home_input_hint'.tr,
                          hintStyle: TextStyle(
                            color: context.color.textBody,
                            fontSize: 15,
                          ),
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
                      Expanded(
                        child: Obx(() {
                          if (controller.isListening.value) {
                            return _VoiceWaveform(
                              levels: controller.soundLevels.toList(),
                            );
                          }
                          final action = controller.selectedAction.value;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: action == null
                                ? const SizedBox.shrink()
                                : _ActionTag(
                                    action: action,
                                    onClear: controller.onClearAction,
                                  ),
                          );
                        }),
                      ),
                      Obx(
                        () => controller.isListening.value
                            ? IconButton(
                                onPressed: controller.onCancelVoice,
                                icon: Icon(
                                  PhosphorIconsRegular.x,
                                  size: 20,
                                  color: context.color.textBody,
                                ),
                              )
                            : IconButton(
                                onPressed: controller.onMic,
                                icon: Icon(
                                  PhosphorIconsRegular.microphone,
                                  size: 22,
                                  color: context.color.textNatural,
                                ),
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
            () => controller.isListening.value
                ? _RoundButton(
                    icon: PhosphorIconsRegular.paperPlaneRight,
                    onTap: controller.onSendVoice,
                  )
                : controller.isGenerating.value
                ? _RoundButton(
                    icon: PhosphorIconsFill.pause,
                    onTap: controller.onStop,
                  )
                : controller.canSend
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

/// Live mic levels as bars, with dots for the space still to fill.
class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform({required this.levels});

  /// 0..1, oldest first.
  final List<double> levels;

  static const _step = 5.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slots = (constraints.maxWidth / _step).floor();
          final shown = levels.length > slots
              ? levels.sublist(levels.length - slots)
              : levels;
          return Row(
            children: [
              for (var i = 0; i < slots; i++)
                SizedBox(
                  width: _step,
                  child: Center(
                    child: i < shown.length
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: 2,
                            height: 4 + 22 * shown[i],
                            decoration: BoxDecoration(
                              color: context.color.textNatural,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                        : Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              color: context.color.textBody,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The photo or document waiting to be sent, with a remove x.
class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment, required this.onRemove});

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 4, 6),
      decoration: BoxDecoration(
        color: context.color.tileFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.color.tileBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: attachment.isImage
                ? Image.memory(
                    attachment.bytes,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    cacheWidth: 108,
                  )
                : SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      PhosphorIconsRegular.fileText,
                      size: 22,
                      color: context.color.textNatural,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: CustomText(
              attachment.name,
              maxLines: 1,
              fontSize: 13,
              color: context.color.textNatural,
            ),
          ),
          InkResponse(
            onTap: onRemove,
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
