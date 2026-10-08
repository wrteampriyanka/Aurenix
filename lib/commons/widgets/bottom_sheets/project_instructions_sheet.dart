import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/features/widgets/app_button.dart';
import 'package:aurenix/features/widgets/app_text_field.dart';
import 'package:aurenix/features/widgets/custom_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';

/// The sheet behind "Edit Project" and "Add Instructions": one multi-line
/// field holding what the assistant should keep in mind for this project.
///
/// Resolves with the saved text, or null when dismissed without saving.
class ProjectInstructionsSheet extends StatefulWidget {
  const ProjectInstructionsSheet({super.key, this.initialText = ''});

  /// Instructions the project already carries, if any.
  final String initialText;

  static Future<String?> show({String initialText = ''}) {
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
      builder: (_) => ProjectInstructionsSheet(initialText: initialText),
    );
  }

  @override
  State<ProjectInstructionsSheet> createState() =>
      _ProjectInstructionsSheetState();
}

class _ProjectInstructionsSheetState extends State<ProjectInstructionsSheet> {
  late final _text = TextEditingController(text: widget.initialText);

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back(result: _text.text.trim());
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    return Padding(
      // Lifts the sheet above the keyboard while the instructions are typed.
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(
                        'projects_instructions_title'.tr,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                        color: color.textNatural,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        'projects_instructions_desc'.tr,
                        maxLines: 3,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                        color: color.textBody,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        controller: _text,
                        hint: 'projects_instructions_hint'.tr,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 5,
                        maxLines: 8,
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: 'projects_instructions_save'.tr,
                        icon: null,
                        height: 54,
                        fontSize: 17,
                        onPressed: _save,
                      ),
                    ],
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
