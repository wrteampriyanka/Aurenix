import 'package:flutter/painting.dart';

/// The type scale.
///
/// These are the sizes the app already uses, given names. Nothing here
/// changes how anything looks; the point is that a size lives in one place,
/// so changing "the size of a section heading" is one edit rather than a
/// find-and-replace across the project.
///
/// Pick the name that matches what the text *is*, not the number that
/// happens to match today.
class AppFontSize {
  AppFontSize._();

  /// The limit sheet's big count.
  static const double display = 40;

  /// Screen titles on the auth and splash screens.
  static const double title = 32;

  /// Onboarding headline, and the limit sheet's second line.
  static const double headline = 30;

  /// Bottom sheet titles.
  static const double sheetTitle = 26;

  /// Markdown h1 in a reply, and the home greeting.
  static const double h1 = 22;

  /// Section headings on the upgrade and checkout screens.
  static const double h2 = 20;

  /// Markdown h2 in a reply.
  static const double markdownH2 = 19;

  /// Card titles.
  static const double h3 = 18;

  /// Markdown h3 in a reply, and a sheet's secondary line.
  static const double markdownH3 = 17;

  /// Default body text, and what a text field shows.
  static const double body = 16;

  /// Chat message text and the chat input.
  static const double chat = 15;

  /// The most common size: list rows, buttons, most labels.
  static const double label = 14;

  /// Secondary text under a label.
  static const double caption = 13;

  /// Section labels above a field, and metadata.
  static const double overline = 12;

  /// The file-type badge on a project file.
  static const double badge = 10;
}

/// The weights in use. The app ships Space Grotesk at 300-700, but only
/// these four are set explicitly; anything else inherits [regular].
class AppFontWeight {
  AppFontWeight._();

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
}
