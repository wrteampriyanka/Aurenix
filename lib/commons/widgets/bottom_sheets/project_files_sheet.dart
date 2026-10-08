import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/commons/widgets/app_button.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// A file attached to a project.
class ProjectFile {
  const ProjectFile({
    required this.id,
    required this.name,
    required this.bytes,
  });

  final String id;
  final String name;
  final int bytes;

  /// [bytes] in the largest unit that keeps it at or above one, e.g. "23 MB".
  String get sizeLabel {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final digits = unit == 0 || size >= 10 ? 0 : 1;
    return '${size.toStringAsFixed(digits)} ${units[unit]}';
  }
}

/// The sheet behind a project's file button: the files the project holds,
/// each removable, with a button to upload more. The list is watched, so
/// uploads and removals show up while the sheet is open.
class ProjectFilesSheet extends StatelessWidget {
  const ProjectFilesSheet({
    super.key,
    required this.files,
    required this.onUpload,
    required this.onRemove,
  });

  final RxList<ProjectFile> files;
  final VoidCallback onUpload;
  final ValueChanged<ProjectFile> onRemove;

  static Future<void> show({
    required RxList<ProjectFile> files,
    required VoidCallback onUpload,
    required ValueChanged<ProjectFile> onRemove,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 380),
        reverseDuration: Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => ProjectFilesSheet(
        files: files,
        onUpload: onUpload,
        onRemove: onRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    // Full width and attached to the bottom edge, with the background running
    // under the system navigation bar and only the content kept clear of it.
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: color.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: AppSpacing.xl),
            AppText(
              AppStrings.projectFilesTitle.tr,
              fontSize: AppFontSize.sheetTitle,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
              color: color.textNatural,
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Obx(() {
                  if (files.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: AppText(
                        AppStrings.projectFilesEmpty.tr,
                        fontSize: AppFontSize.label,
                        textAlign: TextAlign.center,
                        color: color.textBody,
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: files.length,
                    itemBuilder: (_, i) => _FileRow(
                      file: files[i],
                      onRemove: () => onRemove(files[i]),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: AppButton(
                label: AppStrings.projectFilesUpload.tr,
                icon: null,
                height: 50,
                fontSize: AppFontSize.body,
                onPressed: onUpload,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.onRemove});

  final ProjectFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.tileBorder),
            ),
            child: Icon(
              PhosphorIconsRegular.fileText,
              size: 22,
              color: color.error,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  file.name,
                  maxLines: 1,
                  fontSize: AppFontSize.body,
                  fontWeight: FontWeight.w600,
                  color: color.textNatural,
                ),
                const SizedBox(height: 2),
                AppText(
                  file.sizeLabel,
                  fontSize: AppFontSize.overline,
                  color: color.textBody,
                ),
              ],
            ),
          ),
          PopupMenuButton<void>(
            tooltip: '',
            color: color.sheetCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
            icon: Icon(
              PhosphorIconsRegular.dotsThree,
              size: 18,
              color: color.textBody,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: onRemove,
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.trash,
                      size: 18,
                      color: color.error,
                    ),
                    const SizedBox(width: 10),
                    AppText(
                      AppStrings.projectFilesRemove.tr,
                      fontSize: AppFontSize.label,
                      color: color.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
