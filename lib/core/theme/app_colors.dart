import 'package:flutter/material.dart';

/// The app palette.
///
/// Aurenix is dark-only: there is no light theme and the OS appearance
/// setting is ignored. Every value here is a dark-surface value, so a widget
/// that takes no explicit colour still renders correctly.
///
/// Organised by role, not by screen. The semantic core at the top is what a
/// new screen should reach for; the named roles below it are defined from
/// that core, so changing a surface or a hairline moves everything that uses
/// it instead of leaving two screens to drift apart.
///
/// Use as `appColors.primary`. It is a plain value, not a lookup: with one
/// theme there is nothing for a [BuildContext] to select.
class AppColors {
  const AppColors._();

  static const AppColors instance = AppColors._();

  // ===================================================================
  // Semantic core — reach for these first.
  // ===================================================================

  /// The flat dark base every screen paints.
  final Color surface = const Color(0xFF11141A);

  /// A card or sheet raised above [surface].
  final Color surfaceVariant = const Color(0xFF1A1F2B);

  /// Text and icons on [surface].
  final Color onSurface = const Color(0xFFECF2FD);

  /// Secondary text: labels, captions, placeholder text.
  final Color onSurfaceMuted = const Color(0xFF95A3C2);

  /// Hairline border or divider on a dark surface.
  final Color outline = const Color(0x14FFFFFF);

  /// A border meant to be seen: card edges, dividers between sections.
  final Color outlineStrong = const Color(0x33FFFFFF);

  /// Translucent white fill for a tile sitting on a dark surface.
  final Color fill = const Color(0x0DFFFFFF);

  /// [fill] for a tile that is highlighted or selected.
  final Color fillStrong = const Color(0x1AFFFFFF);

  /// Scrim behind a drawer or modal.
  final Color scrim = const Color(0x99000000);

  // ===================================================================
  // Brand
  // ===================================================================

  /// Shades/primary/400.
  final Color primary = const Color(0xFF2563EB);
  final Color secondary = const Color(0xFF10B981);
  final Color error = const Color(0xFFEF4444);

  /// Shades/primary/50: a pale blue for icons on a primary fill.
  final Color primaryShade50 = const Color(0xFFEFF6FF);

  /// Primary button gradient highlight and border.
  final Color buttonHighlight = const Color(0xFF7FA2F5);
  final Color buttonBorder = const Color(0xFF5A8AF2);

  // ===================================================================
  // Text
  // ===================================================================

  /// What [AppText] and the theme fall back to: [onSurface].
  final Color textPrimary = const Color(0xFFECF2FD);

  /// [onSurfaceMuted] under its older name.
  final Color textSecondary = const Color(0xFF95A3C2);

  /// Alias of [onSurface], kept because much of the app reads this name.
  final Color textNatural = const Color(0xFFECF2FD);

  /// Alias of [onSurfaceMuted].
  final Color textBody = const Color(0xFF95A3C2);

  /// Text and icons on a filled primary button.
  final Color textOnPrimary = const Color(0xFFFFFFFF);
  final Color iconOnPrimary = const Color(0xFFEFF6FF);

  /// Text on a light fill, e.g. the social sign-in buttons.
  final Color textOnLight = const Color(0xFF111827);

  // ===================================================================
  // Surfaces
  // ===================================================================

  /// Aliases of [surface] / [surfaceVariant].
  final Color backgroundPrimary = const Color(0xFF11141A);
  final Color backgroundSecondary = const Color(0xFF1A1F2B);
  final Color backgroundBase = const Color(0xFF11141A);
  final Color surfaceDark = const Color(0xFF1A1F2B);

  /// Darker than [surface], behind the gradient on AppBackground.
  final Color backgroundDark = const Color(0xFF0B0F19);
  final Color backgroundDarkSecondary = const Color(0xFF111827);
  final Color backgroundGlow = const Color(0xFF1D4ED8);

  /// AppBackground gradient: bright blue top → flat dark base.
  final Color backgroundTop = const Color(0xFF1560C8);
  final Color backgroundTopFade = const Color(0xFF122658);

  /// Soft teal glow behind the status bar on plain screens.
  final Color topGlow = const Color(0xFF0E4A5C);

  /// Deep blue band at the top of the screen, left → right.
  final List<Color> backgroundTopBand = const [
    Color(0xFF1A50B8),
    Color(0xFF1C58D4),
    Color(0xFF1756DA),
    Color(0xFF0F46D8),
    Color(0xFF0E3FCC),
    Color(0xFF0E2A80),
    Color(0xFF0E2262),
  ];

  /// Alias of [outline] / [outlineStrong] / [fill] / [fillStrong] / [scrim].
  final Color strokeDark = const Color(0x1AFFFFFF);
  final Color tileFill = const Color(0x0DFFFFFF);
  final Color tileFillHighlight = const Color(0x1AFFFFFF);
  final Color tileBorder = const Color(0x14FFFFFF);
  final Color divider = const Color(0x33FFFFFF);
  final Color sidebarScrim = const Color(0x99000000);

  /// Shadow under a raised card, and under the switch thumb.
  final Color cardShadow = const Color(0x66000000);
  final Color switchShadow = const Color(0x33000000);

  // ===================================================================
  // Components
  // ===================================================================

  /// Text fields.
  final Color inputFill = const Color(0xFF1C2230);
  final Color inputBorder = const Color(0x14FFFFFF);

  /// Social sign-in buttons: a light pill, so its text is [textOnLight].
  final Color socialButtonFill = const Color(0xFFE8EEFB);

  /// Sidebar drawer and its search.
  final Color sidebarBackground = const Color(0xFF1A1F29);
  final Color sidebarCard = const Color(0x08FFFFFF);
  final Color sidebarSelected = const Color(0xFF28303F);

  /// Bottom sheets.
  final Color sheetBackground = const Color(0xFF12151C);
  final Color sheetCard = const Color(0xFF1E222B);
  final Color sheetHandle = const Color(0xFF2E3441);

  /// Profile.
  final Color profileMenuCard = const Color(0xFF1C2029);
  final Color profileCardFill = const Color(0x14FFFFFF);
  final Color profileCardBorder = const Color(0x33FFFFFF);
  final Color profileCardDivider = const Color(0x14FFFFFF);

  /// Upgrade button: dark pill with a soft grey glow.
  final Color upgradeButton = const Color(0xFF0B0D12);
  final Color upgradeButtonHighlight = const Color(0xFF3A3F4B);
  final Color upgradeButtonBorder = const Color(0x33FFFFFF);

  /// AppSwitch.
  final Color switchTrackOff = const Color(0xFF3A4150);
  final Color switchThumb = const Color(0xFFFFFFFF);

  /// Presets: the rating star, the ranked tile's numbered badge, the detail
  /// screen's rating bars, and the blue tint on its category strip.
  final Color ratingStar = const Color(0xFFFBBF24);
  final Color rankBadge = const Color(0xFF3A4150);
  final Color rankBadgeBorder = const Color(0x1FFFFFFF);
  final Color ratingBarTrack = const Color(0xFF232A3A);
  final Color ratingBarFill = const Color(0xFF2563EB);
  final Color cardStripTint = const Color(0x4D1D3B8A);

  /// Onboarding orb.
  final Color orbLight = const Color(0xFF60A5FA);
  final Color orbDeep = const Color(0xFF1E40AF);
  final Color accentPurple = const Color(0xFF8B5CF6);
  final Color orbBright = const Color(0xFF1E9BFF);
  final Color orbBase = const Color(0xFF3B6FF5);
  final Color orbRing = const Color(0x33FFFFFF);

  /// Onboarding integration hub.
  final Color platformIcon = const Color(0xFF5B6272);
  final Color appIconMuted = const Color(0xFFC9CDD4);
  final Color connectorLine = const Color(0x803B5BA5);

  /// Services sheet tiles, one colour per service.
  final Color serviceAttach = const Color(0xFF2563EB);
  final Color serviceCapture = const Color(0xFF5B21B6);
  final Color serviceCode = const Color(0xFFEF4444);
  final Color serviceIntegration = const Color(0xFF22C55E);
  final Color serviceResearch = const Color(0xFFF59E0B);
  final Color serviceGenerateImage = const Color(0xFFA855F7);

  // ===================================================================
  // Swatches — pick from these instead of writing a Color literal.
  // ===================================================================

  /// Avatar and author circles: collaborators, and who started a chat.
  final List<Color> avatarSwatch = const [
    Color(0xFF2563EB),
    Color(0xFFB45309),
    Color(0xFF0F766E),
    Color(0xFF7C3AED),
    Color(0xFFBE123C),
  ];

  /// What a project's folder icon can be tinted, offered in the create
  /// project sheet.
  final List<Color> projectIconSwatch = const [
    Color(0xFFFFFFFF),
    Color(0xFFFACC15),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF38BDF8),
    Color(0xFF2DD4BF),
  ];
}

/// The palette. A plain value: with one theme there is nothing to look up.
const appColors = AppColors.instance;
