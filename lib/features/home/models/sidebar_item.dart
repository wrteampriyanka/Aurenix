import 'package:flutter/material.dart';

/// What a sidebar menu row does when tapped.
enum SidebarAction { newChat, temporaryChat, presets, newProject, viewAll }

/// A row in one of the sidebar menu cards.
class SidebarItem {
  const SidebarItem({
    required this.action,
    required this.labelKey,
    this.icon,
    this.iconAsset,
    this.iconColor,
    this.showArrow = false,
  }) : assert(icon != null || iconAsset != null, 'give an icon or an asset');

  final SidebarAction action;

  /// Translation key of the label.
  final String labelKey;

  /// A font icon, or null when [iconAsset] is used instead.
  final IconData? icon;

  /// An SVG from `assets/images`, tinted like a font icon.
  final String? iconAsset;

  /// Tint of the icon; defaults to the regular text colour.
  final Color? iconColor;
  final bool showArrow;
}
