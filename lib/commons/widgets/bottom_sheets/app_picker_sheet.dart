import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/commons/widgets/app_search_field.dart';
import 'package:aurenix/commons/widgets/app_text.dart';
import 'package:aurenix/core/theme/app_text_styles.dart';
import 'package:aurenix/core/theme/app_spacing.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Floating sheet with a search field over a list of options. Opens scrolled
/// to the current [selected] option and resolves with the one tapped, or
/// null when dismissed.
///
/// ```dart
/// final country = await AppPickerSheet.show(
///   title: 'Country',
///   items: countries,
///   labelOf: (c) => c.name,
///   selected: current,
/// );
/// ```
class AppPickerSheet<T> extends StatefulWidget {
  const AppPickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.labelOf,
    this.selected,
    this.leadingOf,
    this.searchHint,
  });

  final String title;
  final List<T> items;
  final String Function(T item) labelOf;
  final T? selected;

  /// Optional widget before each label, e.g. a flag.
  final Widget Function(T item)? leadingOf;

  /// Defaults to `picker_search_hint`.
  final String? searchHint;

  static Future<T?> show<T>({
    required String title,
    required List<T> items,
    required String Function(T item) labelOf,
    T? selected,
    Widget Function(T item)? leadingOf,
    String? searchHint,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<T>(
      context: Get.context!,
      isScrollControlled: true,
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
      builder: (_) => AppPickerSheet<T>(
        title: title,
        items: items,
        labelOf: labelOf,
        selected: selected,
        leadingOf: leadingOf,
        searchHint: searchHint,
      ),
    );
  }

  @override
  State<AppPickerSheet<T>> createState() => _AppPickerSheetState<T>();
}

class _AppPickerSheetState<T> extends State<AppPickerSheet<T>> {
  static const double _rowHeight = 52;

  final _search = TextEditingController();
  late final ScrollController _scroll;
  late List<T> _matches = widget.items;

  @override
  void initState() {
    super.initState();
    // Start with the current option a couple of rows below the top.
    final index = widget.selected == null
        ? -1
        : widget.items.indexOf(widget.selected as T);
    _scroll = ScrollController(
      initialScrollOffset: index > 2 ? (index - 2) * _rowHeight : 0,
    );
    _search.addListener(_filter);
  }

  void _filter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _matches = q.isEmpty
          ? widget.items
          : [
              for (final item in widget.items)
                if (widget.labelOf(item).toLowerCase().contains(q)) item,
            ];
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = appColors;
    final media = MediaQuery.of(context);
    return Padding(
      // Lifts the sheet above the keyboard while searching.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          height: media.size.height * 0.72,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: color.sheetBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.tileBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: AppText(
                  widget.title,
                  maxLines: 1,
                  fontSize: AppFontSize.h3,
                  fontWeight: FontWeight.w600,
                  color: color.textNatural,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppSearchField(
                  controller: _search,
                  hintText: widget.searchHint ?? AppStrings.pickerSearchHint.tr,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _matches.isEmpty
                    ? Center(
                        child: AppText(
                          AppStrings.pickerNoResults.tr,
                          fontSize: AppFontSize.label,
                          color: color.textBody,
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                        itemExtent: _rowHeight,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: _matches.length,
                        itemBuilder: (_, i) => _row(context, _matches[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, T item) {
    final color = appColors;
    final selected = item == widget.selected;
    return Material(
      color: selected ? color.sheetCard : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (widget.leadingOf case final leading?) ...[
                leading(item),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: AppText(
                  widget.labelOf(item),
                  maxLines: 1,
                  fontSize: AppFontSize.chat,
                  color: color.textNatural,
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
