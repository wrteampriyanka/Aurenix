import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_text_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Which chats a project's assistant may remember.

/// Everything [CreateProjectSheet] collects about a new project.
class ProjectDraft {
  const ProjectDraft({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.memory,
  });

  final String name;
  final IconData icon;
  final Color iconColor;
  final ProjectMemory memory;
}

/// Three sheets in a row, each one opening from what the user just did:
/// naming the project opens the memory preference, choosing that opens the
/// colour and icon. There is nothing to press to move on — only the final
/// Create button — and the icon tile, name field and card outline stay put
/// across all three so it reads as one sheet growing.
///
/// Opened again with an [initial] draft it becomes the Edit Project sheet:
/// the same card, minus the memory step, straight on the name, colour and
/// icon with a Save button.
///
/// Resolves with the finished [ProjectDraft], or null when dismissed.
class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key, this.initial});

  /// The project being edited, or null when one is being created.
  final ProjectDraft? initial;

  /// Swatches offered on the last sheet.
  static final colors = appColors.projectIconSwatch;

  /// Icons offered on the last sheet, laid out nine to a row over three rows.
  static const icons = [
    PhosphorIconsRegular.envelopeSimple,
    PhosphorIconsRegular.lock,
    PhosphorIconsRegular.eyeSlash,
    PhosphorIconsRegular.userCircle,
    PhosphorIconsRegular.sidebarSimple,
    PhosphorIconsRegular.user,
    PhosphorIconsRegular.plus,
    PhosphorIconsRegular.microphone,
    PhosphorIconsRegular.waveform,
    PhosphorIconsRegular.slidersHorizontal,
    PhosphorIconsRegular.lightning,
    PhosphorIconsRegular.copy,
    PhosphorIconsRegular.speakerHigh,
    PhosphorIconsRegular.arrowsClockwise,
    PhosphorIconsRegular.lightbulb,
    PhosphorIconsRegular.image,
    PhosphorIconsRegular.paperclip,
    PhosphorIconsRegular.bookOpen,
    PhosphorIconsRegular.magnifyingGlass,
    PhosphorIconsRegular.chatCentered,
    PhosphorIconsRegular.puzzlePiece,
    PhosphorIconsRegular.pencilSimple,
    PhosphorIconsRegular.gear,
    PhosphorIconsRegular.code,
    PhosphorIconsRegular.star,
    PhosphorIconsRegular.heart,
    PhosphorIconsRegular.rocket,
  ];

  static Future<ProjectDraft?> show() {
    return showModalBottomSheet<ProjectDraft>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 450),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const CreateProjectSheet(),
    );
  }

  /// The same sheet over an existing project: its name, colour and icon
  /// ready to be changed. Resolves with the edited draft, or null.
  static Future<ProjectDraft?> edit(ProjectDraft initial) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<ProjectDraft>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 450),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => CreateProjectSheet(initial: initial),
    );
  }

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

/// The three sheets, in the order they open.
enum _Step { memory, look }

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  /// How long the body takes to swap, and how long a tapped option is left
  /// on screen first so its tick is seen before the next sheet slides in.
  static const _swap = Duration(milliseconds: 340);
  static const _settle = Duration(milliseconds: 260);

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  final _nameFocus = FocusNode();

  /// Editing skips straight to the look: the memory choice was made when
  /// the project was created.
  late _Step _step = _isEditing ? _Step.look : _Step.memory;

  late ProjectMemory? _memory = widget.initial?.memory;
  late Color _color = widget.initial?.iconColor ?? CreateProjectSheet.colors[1];
  late IconData _icon = widget.initial?.icon ?? PhosphorIconsRegular.lightbulb;

  bool get _isEditing => widget.initial != null;

  /// Unfocuses the name field when the user presses done on the keyboard.
  void _onNameSubmitted() {
    _nameFocus.unfocus();
  }

  /// Ticks the chosen preference, then opens the colour and icon sheet.
  void _onMemory(ProjectMemory value) {
    // Dismiss the keyboard before transitioning so it doesn't re-open.
    _nameFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _memory = value);
    Future.delayed(_settle, () {
      if (!mounted || _step != _Step.memory) return;
      setState(() => _step = _Step.look);
    });
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    Get.back(
      result: ProjectDraft(
        name: _name.text.trim(),
        icon: _icon,
        iconColor: _color,
        memory: _memory ?? ProjectMemory.all,
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  /// The outgoing sheet slides off to the left as the incoming one arrives
  /// from the right, both fading, so the swap reads as one forward move.
  Widget _transition(Widget child, Animation<double> animation) {
    final incoming = (child.key as ValueKey<_Step>).value == _step;
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: Offset(incoming ? 0.22 : -0.22, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  Widget _body() {
    switch (_step) {
      case _Step.memory:
        return _MemoryStep(value: _memory, onChanged: _onMemory);
      case _Step.look:
        return _LookStep(
          color: _color,
          icon: _icon,
          onColor: (v) => setState(() => _color = v),
          onIcon: (v) => setState(() => _icon = v),
          onCreate: _create,
          actionLabel: _isEditing
              ? AppStrings.projectsInstructionsSave.tr
              : AppStrings.continueKey.tr,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Padding(
      // Lifts the sheet above the keyboard while the name is being typed.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: color.sheetBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.tileBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: color.sheetHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppText(
                          _isEditing
                              ? AppStrings.projectsMenuEdit.tr
                              : AppStrings.sidebarNewProject.tr,
                          fontSize: AppFontSize.h3,
                          fontWeight: FontWeight.w600,
                          color: color.textNatural,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Header(
                          controller: _name,
                          focusNode: _nameFocus,
                          icon: _icon,
                          color: _color,
                          onSubmitted: _onNameSubmitted,
                        ),
                        const SizedBox(height: 18),
                        AnimatedSize(
                          duration: _swap,
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: _swap,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.topCenter,
                              children: [...previous, ?current],
                            ),
                            transitionBuilder: _transition,
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _body(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon tile and name field, shared by all three sheets. The tile wears the
/// colour and icon being picked, so the last sheet previews itself as it is
/// edited, and the name stays editable throughout.
class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.color,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final Color color;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appColors.sheetCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(icon, key: ValueKey(icon), size: 24, color: color),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            controller: controller,
            focusNode: focusNode,
            hint: AppStrings.projectsNameHint.tr,
            textInputAction: TextInputAction.done,
            validator: (v) => (v ?? '').trim().isEmpty
                ? AppStrings.projectsNameRequired.tr
                : null,
            onFieldSubmitted: (_) => onSubmitted(),
          ),
        ),
      ],
    );
  }
}

/// Sheet two — how much of the user's history this project may draw on.
/// Picking either option opens the next sheet on its own.
class _MemoryStep extends StatelessWidget {
  const _MemoryStep({required this.value, required this.onChanged});

  final ProjectMemory? value;
  final ValueChanged<ProjectMemory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepLabel(AppStrings.projectsMemoryLabel.tr),
        const SizedBox(height: AppSpacing.md),
        _OptionTile(
          title: AppStrings.projectsMemoryDefault.tr,
          subtitle: AppStrings.projectsMemoryDefaultDesc.tr,
          selected: value == ProjectMemory.all,
          onTap: () => onChanged(ProjectMemory.all),
        ),
        const SizedBox(height: 10),
        _OptionTile(
          title: AppStrings.projectsMemoryOnly.tr,
          subtitle: AppStrings.projectsMemoryOnlyDesc.tr,
          selected: value == ProjectMemory.projectOnly,
          onTap: () => onChanged(ProjectMemory.projectOnly),
        ),
      ],
    );
  }
}

/// Sheet three — the colour swatches, the icon grid and the Create button.
class _LookStep extends StatelessWidget {
  const _LookStep({
    required this.color,
    required this.icon,
    required this.onColor,
    required this.onIcon,
    required this.onCreate,
    required this.actionLabel,
  });

  final Color color;
  final IconData icon;
  final ValueChanged<Color> onColor;
  final ValueChanged<IconData> onIcon;
  final VoidCallback onCreate;

  /// "Continue" when creating, "Save Changes" when editing.
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final swatch in CreateProjectSheet.colors)
              _Swatch(
                color: swatch,
                selected: swatch.toARGB32() == color.toARGB32(),
                onTap: () => onColor(swatch),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: CreateProjectSheet.icons.length,
          itemBuilder: (_, i) {
            final option = CreateProjectSheet.icons[i];
            return _IconCell(
              icon: option,
              color: color,
              selected: option == icon,
              onTap: () => onIcon(option),
            );
          },
        ),
        const SizedBox(height: 18),
        AppButton(
          label: actionLabel,
          icon: null,
          height: 50,
          fontSize: AppFontSize.body,
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppText(
        text,
        fontSize: AppFontSize.caption,
        color: appColors.textBody,
      ),
    );
  }
}

/// A bordered radio row with a title, a description and a trailing check.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: color.sheetCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color.primary : color.tileBorder,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        maxLines: 1,
                        fontSize: AppFontSize.chat,
                        fontWeight: FontWeight.w600,
                        color: color.textNatural,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText(
                        subtitle,
                        maxLines: 2,
                        fontSize: AppFontSize.overline,
                        color: color.textBody,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color.primary : color.tileFillHighlight,
                  ),
                  child: Icon(
                    PhosphorIconsRegular.check,
                    size: 14,
                    color: selected ? color.textOnPrimary : color.textBody,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One colour circle; the selected one wears a ring in its own colour.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 34,
        height: 34,
        padding: EdgeInsets.all(selected ? 4 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

/// One cell of the icon grid; the selected one fills with the chosen colour.
class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Icon(
          icon,
          size: 17,
          color: selected ? color : theme.textNatural,
        ),
      ),
    );
  }
}
