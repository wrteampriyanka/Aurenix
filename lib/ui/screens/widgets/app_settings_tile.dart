import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/app_colors.dart';
import 'app_switch.dart';
import 'custom_text.dart';

/// Title, subtitle and an on/off switch on a rounded card.
class AppToggleCard extends StatelessWidget {
  const AppToggleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: context.color.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  maxLines: 1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.color.textNatural,
                ),
                const SizedBox(height: 4),
                CustomText(
                  subtitle,
                  maxLines: 2,
                  fontSize: 12,
                  color: context.color.textBody,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Tappable card with an icon, a title and a trailing caret.
///
/// With a [subtitle], the icon sits in a round badge and the subtitle shows
/// under the title; without one it is a compact single-line row.
class AppSettingsTile extends StatelessWidget {
  const AppSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Material(
      color: context.color.inputFill,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: subtitle == null
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
              : const EdgeInsets.all(12),
          child: Row(
            children: [
              if (subtitle == null)
                Icon(icon, size: 22, color: context.color.textNatural)
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.color.tileFillHighlight,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: context.color.textNatural,
                  ),
                ),
              SizedBox(width: subtitle == null ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      maxLines: 1,
                      fontSize: subtitle == null ? 14 : 16,
                      fontWeight: subtitle == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: context.color.textNatural,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      CustomText(
                        subtitle,
                        maxLines: 2,
                        fontSize: 12,
                        color: context.color.textBody,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18,
                color: context.color.textNatural,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
