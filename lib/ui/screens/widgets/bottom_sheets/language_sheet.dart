import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../custom_text.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Floating sheet listing the app languages. Tapping one switches the app
/// to it (the highlight moves at once) and then closes the sheet.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  /// Resolves once the sheet is closed.
  static Future<void> show() {
    return showModalBottomSheet<void>(
      context: Get.context!,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 420),
        reverseDuration: Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const LanguageSheet(),
    );
  }

  Future<void> _pick(BuildContext context, AppLanguage language) async {
    final service = LanguageService.instance;
    if (service.switching.value) return;
    if (language != service.selected.value) {
      await service.select(language);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    final service = LanguageService.instance;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: color.sheetBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.tileBorder),
        ),
        clipBehavior: Clip.antiAlias,
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: CustomText(
                'language_title'.tr,
                maxLines: 1,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color.textNatural,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              // Rebuilds as soon as a language is picked, so the check mark
              // moves to the tapped row before the sheet closes.
              child: Obx(
                () => Column(
                  children: [
                    for (final language in LanguageService.languages)
                      _LanguageRow(
                        language: language,
                        selected: language == service.selected.value,
                        onTap: () => _pick(context, language),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.color;
    final name = language.nameKey.tr;
    // "English" in English needs no second line.
    final native = name == language.nativeName ? null : language.nativeName;
    return Material(
      color: selected ? color.sheetCard : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      name,
                      maxLines: 1,
                      fontSize: 15,
                      color: color.textNatural,
                    ),
                    if (native != null) ...[
                      const SizedBox(height: 2),
                      CustomText(
                        native,
                        maxLines: 1,
                        fontSize: 13,
                        color: color.textBody,
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(PhosphorIconsBold.check, size: 18, color: color.primary),
            ],
          ),
        ),
      ),
    );
  }
}
