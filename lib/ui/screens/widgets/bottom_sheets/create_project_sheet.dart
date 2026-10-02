import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../app_button.dart';
import '../app_text_field.dart';
import '../custom_text.dart';
import '../../../../core/theme/app_colors.dart';

/// Bottom sheet asking for a new project's name. Resolves with the trimmed
/// name, or null when dismissed.
class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key});

  static const double _radius = 28;

  static Future<String?> show() => Get.bottomSheet<String>(
    const CreateProjectSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
  );

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Get.back(result: _name.text.trim());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    // Get.bottomSheet already lifts the sheet above the keyboard.
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CreateProjectSheet._radius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.backgroundBase,
          border: Border(top: BorderSide(color: color.strokeDark)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomText(
                    'sidebar_new_project'.tr,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: color.textNatural,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _name,
                    hint: 'projects_name_hint'.tr,
                    prefixIcon: PhosphorIconsRegular.folder,
                    textInputAction: TextInputAction.done,
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'projects_name_required'.tr
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'projects_create'.tr,
                    icon: PhosphorIconsRegular.folderPlus,
                    height: 52,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
