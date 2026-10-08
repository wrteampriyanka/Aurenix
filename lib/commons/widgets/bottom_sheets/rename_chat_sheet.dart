import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_text_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';

/// The sheet behind "Rename" in the chat menu: one line holding the chat's
/// title, opened with the current one selected so typing replaces it.
///
/// Resolves with the new title, or null when dismissed or left empty.
class RenameChatSheet extends StatefulWidget {
  const RenameChatSheet({super.key, this.initialTitle = ''});

  final String initialTitle;

  static Future<String?> show({String initialTitle = ''}) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<String>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => RenameChatSheet(initialTitle: initialTitle),
    );
  }

  @override
  State<RenameChatSheet> createState() => _RenameChatSheetState();
}

class _RenameChatSheetState extends State<RenameChatSheet> {
  late final _title = TextEditingController(text: widget.initialTitle)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialTitle.length,
    );
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Opens the keyboard once the sheet has settled, so it does not fight
    // the slide-up animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back(result: title);
  }

  @override
  void dispose() {
    _title.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Padding(
      // Lifts the sheet above the keyboard while the title is typed.
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.sheetHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      'chat_menu_rename_title'.tr,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                      color: color.textNatural,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _title,
                      hint: 'chat_menu_rename_hint'.tr,
                      focusNode: _focus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'chat_menu_rename_save'.tr,
                      icon: null,
                      height: 54,
                      fontSize: 17,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
