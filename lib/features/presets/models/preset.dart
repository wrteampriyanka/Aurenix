/// The filter chips under the search field.
enum PresetFilter {
  handPicked('presets_filter_hand_picked'),
  trending('presets_filter_trending'),
  features('presets_filter_features'),
  business('presets_filter_business'),
  education('presets_filter_education');

  const PresetFilter(this.labelKey);

  /// Translation key of the chip label.
  final String labelKey;
}

/// How a group of presets is drawn on the Hand Picked tab.
enum PresetGroupLayout {
  /// Avatar on the left, text on the right.
  tile,

  /// Large card with the avatar and text centred.
  featured,

  /// [tile] with a rank number in front.
  ranked,
}

/// A ready-made AI assistant the user can start a chat with.
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.image,
    required this.rating,
    required this.category,
    required this.categoryRank,
    required this.siteUrl,
    required this.conversations,
    required this.reviews,
    required this.ratingBreakdown,
    required this.capabilities,
    required this.quickStarters,
    this.filters = const {},
  });

  final String id;
  final String name;
  final String description;
  final String author;

  /// Bitmap asset shown as the preset's avatar.
  final String image;

  /// Average review score out of 5.
  final double rating;

  /// Where the preset ranks, and in which category, e.g. "#12 - Coding".
  final String category;
  final int categoryRank;

  /// Opened by "Visit Site" on the detail screen.
  final String siteUrl;

  /// Rounded conversation count as shown, e.g. "+65K".
  final String conversations;

  /// Number of reviews behind [rating].
  final int reviews;

  /// Share of reviews with 5, 4, 3, 2 and 1 stars, in that order, 0–1.
  final List<double> ratingBreakdown;

  /// What the preset can do, one line each.
  final List<String> capabilities;

  /// Prompts offered as chips on the detail screen.
  final List<String> quickStarters;

  /// Which filter chips list this preset, besides Hand Picked.
  final Set<PresetFilter> filters;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        author.toLowerCase().contains(q);
  }
}
