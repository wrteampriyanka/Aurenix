import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../commons/widgets/custom_text.dart';
import '../../../core/services/language_service.dart';
import '../../../core/theme/app_colors.dart';

/// Floating sheet listing the app languages. Resolves with the one tapped,
/// or null when dismissed.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key, required this.selected});

  final AppLanguage selected;

  static Future<AppLanguage?> show({required AppLanguage selected}) {
    return showModalBottomSheet<AppLanguage>(
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
      builder: (_) => LanguageSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.color;
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
              child: Column(
                children: [
                  for (final language in LanguageService.languages)
                    _LanguageRow(
                      language: language,
                      selected: language == selected,
                      onTap: () => Navigator.of(context).pop(language),
                    ),
                ],
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
