/// The spacing scale: the 4dp grid the layout mostly sits on.
///
/// These are values the app already uses, given names; nothing here changes
/// any layout. Off-grid gaps (6, 10, 14, 18, 22, 28) are left as literals
/// where they occur — naming them would only be numbers with worse names.
/// Prefer a value from here for anything new.
class AppSpacing {
  AppSpacing._();

  /// Hairline gap between two tightly coupled things.
  static const double xs = 4;

  /// Gap inside a row of related controls.
  static const double sm = 8;

  /// The most common gap: between the rows of a list.
  static const double md = 12;

  /// Screen side padding, and the gap between sections.
  static const double lg = 16;

  /// Gap above a new section.
  static const double xl = 20;

  static const double xxl = 24;

  /// Gap before the bottom of a sheet.
  static const double xxxl = 32;
}

/// Corner radii in use.
class AppRadius {
  AppRadius._();

  static const double sm = 10;

  /// Cards and tiles.
  static const double md = 14;

  /// Bottom sheets and large cards.
  static const double lg = 20;
}
