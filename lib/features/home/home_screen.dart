import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_background.dart';
import 'package:aurenix/commons/widgets/app_top_bar.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/onboarding/widgets/wave_orb.dart';
import 'package:aurenix/features/presets/widgets/preset_widgets.dart';
import 'package:aurenix/features/home/controllers/home_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/features/home/widgets/app_sidebar.dart';
import 'package:aurenix/features/home/widgets/chat_messages.dart';
import 'package:aurenix/features/home/widgets/sidebar_drawer.dart';
import 'package:aurenix/features/home/models/chat_attachment.dart';
import 'package:aurenix/features/home/models/home_action.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebar = Get.find<SidebarController>();
    final scaffold = Scaffold(
      backgroundColor: appColors.sidebarBackground,
      body: SidebarDrawer(
        animation: controller.drawer.position,
        expand: sidebar.search,
        sidebar: const AppSidebar(),
        child: _HomeBody(controller: controller),
      ),
    );
    // Back leaves search, then closes the drawer.
    return Obx(
      () => PopScope(
        canPop: !controller.drawer.isOpen.value,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          sidebar.isSearching.value
              ? sidebar.onSearchBack()
              : controller.drawer.close();
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
      color: appColors.backgroundBase,
      child: AppBackground(
        showGrid: false,
        child: SafeArea(
          child: Column(
            children: [
              Obx(
                () => AppTopBar(
                  onMenu: controller.drawer.toggle,
                  onModelTap: controller.onModelTap,
                  onNewChat: controller.onNewChat,
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
                  text: AppStrings.presetChatNotice.tr,
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
              child: AppText(
                AppStrings.homePrompt.tr,
                fontSize: AppFontSize.h1,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                color: appColors.textBody,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
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
    final color = appColors;
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
            const SizedBox(height: AppSpacing.xs),
            AppText(
              preset.name,
              maxLines: 2,
              fontSize: AppFontSize.h2,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
              color: color.textNatural,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              preset.description,
              maxLines: 3,
              fontSize: AppFontSize.label,
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
          child: PresetSectionTitle(AppStrings.presetsQuickStarters.tr),
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
        side: BorderSide(color: appColors.tileBorder),
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
              AppText(
                action.labelKey.tr,
                fontSize: AppFontSize.chat,
                color: appColors.textNatural,
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
            // Empty state gets the roomy stacked field; once the chat is
            // running the controls move up beside the text on one line.
            child: Obx(
              () => controller.messages.isEmpty
                  ? _stacked(context)
                  : _inline(context),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Obx(
            () => controller.dictation.isListening.value
                ? _RoundButton(
                    icon: PhosphorIconsRegular.paperPlaneRight,
                    onTap: controller.dictation.onSendVoice,
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

  /// Text on top, plus and mic on a row of their own underneath.
  Widget _stacked(BuildContext context) {
    return _shell(
      context: context,
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      children: [
        _attachment(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _field(context),
        ),
        Row(
          children: [
            _attachButton(context),
            Expanded(child: _waveformOrTag(context)),
            _micButton(context),
          ],
        ),
      ],
    );
  }

  /// Plus, text and mic all on one line, so the bar stays short while
  /// messages fill the screen.
  Widget _inline(BuildContext context) {
    return _shell(
      context: context,
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _attachment(),
        Obx(() {
          if (!controller.dictation.isListening.value &&
              controller.selectedAction.value == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: _waveformOrTag(context),
          );
        }),
        Row(
          children: [
            _attachButton(context),
            Expanded(child: _field(context)),
            _micButton(context),
          ],
        ),
      ],
    );
  }

  /// The rounded, bordered box both layouts live in.
  Widget _shell({
    required BuildContext context,
    required EdgeInsets padding,
    required List<Widget> children,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: appColors.inputFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _attachment() {
    return Obx(() {
      final file = controller.attachment.value.value;
      if (file == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: _AttachmentChip(
          attachment: file,
          onRemove: controller.attachment.clear,
        ),
      );
    });
  }

  Widget _field(BuildContext context) {
    return Obx(
      () => TextField(
        controller: controller.messageController,
        focusNode: controller.messageFocus,
        cursorColor: appColors.primary,
        minLines: 1,
        maxLines: 5,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => controller.onSend(),
        style: TextStyle(
          color: appColors.textNatural,
          fontSize: AppFontSize.chat,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: controller.dictation.isListening.value
              ? AppStrings.chatListeningHint.tr
              : controller.isChatLimited
              ? AppStrings.chatLimitHint.tr
              : AppStrings.homeInputHint.tr,
          hintStyle: TextStyle(
            color: appColors.textBody,
            fontSize: AppFontSize.chat,
          ),
        ),
      ),
    );
  }

  Widget _attachButton(BuildContext context) {
    return IconButton(
      onPressed: controller.onAttach,
      icon: Icon(
        PhosphorIconsRegular.plus,
        size: 22,
        color: appColors.textNatural,
      ),
    );
  }

  Widget _micButton(BuildContext context) {
    return Obx(
      () => controller.dictation.isListening.value
          ? IconButton(
              onPressed: controller.dictation.onCancelVoice,
              icon: Icon(
                PhosphorIconsRegular.x,
                size: 20,
                color: appColors.textBody,
              ),
            )
          : IconButton(
              onPressed: controller.dictation.onMic,
              icon: Icon(
                PhosphorIconsRegular.microphone,
                size: 22,
                color: appColors.textNatural,
              ),
            ),
    );
  }

  /// Live mic bars while listening, otherwise the picked action's tag.
  Widget _waveformOrTag(BuildContext context) {
    return Obx(() {
      if (controller.dictation.isListening.value) {
        return _VoiceWaveform(
          levels: controller.dictation.soundLevels.toList(),
        );
      }
      final action = controller.selectedAction.value;
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: action == null
            ? const SizedBox.shrink()
            : _ActionTag(action: action, onClear: controller.onClearAction),
      );
    });
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
                              color: appColors.textNatural,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                        : Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              color: appColors.textBody,
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
        color: appColors.tileFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.tileBorder),
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
                      color: appColors.textNatural,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: AppText(
              attachment.name,
              maxLines: 1,
              fontSize: AppFontSize.caption,
              color: appColors.textNatural,
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
                color: appColors.textBody,
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
        border: Border.all(color: appColors.tileBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(action.icon, width: 16, height: 16),
          const SizedBox(width: AppSpacing.sm),
          AppText(
            action.labelKey.tr,
            fontSize: AppFontSize.caption,
            color: appColors.textNatural,
          ),
          InkResponse(
            onTap: onClear,
            radius: 14,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                PhosphorIconsRegular.x,
                size: 14,
                color: appColors.textBody,
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
        border: Border.all(color: appColors.buttonBorder),
        gradient: RadialGradient(
          center: const Alignment(-0.7, -1.4),
          radius: 1.6,
          colors: [appColors.buttonHighlight, appColors.primary],
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
            child: Icon(icon, size: 24, color: appColors.textNatural),
          ),
        ),
      ),
    );
  }
}
