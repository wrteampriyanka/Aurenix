import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../widgets/app_snackbar.dart';

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

/// Opens [preset]'s site in the browser, with a snackbar if that fails.
Future<void> openPresetSite(Preset preset) async {
  final opened = await launchUrl(
    Uri.parse(preset.siteUrl),
    mode: LaunchMode.externalApplication,
  );
  if (!opened) AppSnackbar.error('chat_open_failed'.tr);
}

/// What the detail screen is opened with: the preset and the tag of the
/// card that was tapped, so the card can fly into the detail header.
class PresetDetailArgs {
  const PresetDetailArgs({required this.preset, required this.heroTag});

  final Preset preset;
  final String heroTag;
}

/// A titled run of presets on the Hand Picked tab.
class PresetGroup {
  const PresetGroup({
    required this.presets,
    required this.layout,
    this.titleKey,
  });

  /// Translation key of the heading; the first group has none.
  final String? titleKey;
  final List<Preset> presets;
  final PresetGroupLayout layout;
}

/// Search, filter chips and the preset lists on the Presets screen.
class PresetsController extends GetxController {
  /// The list's route, so Start Chat on a preset can drop it from the
  /// stack and close straight onto the chat.
  Route<dynamic>? route;

  final searchController = TextEditingController();

  /// Trimmed text of the search field.
  final query = ''.obs;

  final filter = PresetFilter.handPicked.obs;

  // TODO: load the catalogue from the API once it exists.
  static const _spaceScience = Preset(
    id: 'space-science',
    name: 'Space Science Explained AI',
    description: "Best Ai Space for Space science theory's and physics",
    author: 'Jacson Smith',
    image: AppAssets.presetSpace,
    rating: 4.5,
    category: 'Science & Education',
    categoryRank: 3,
    siteUrl: 'https://science.nasa.gov',
    conversations: '+120K',
    reviews: 1240,
    ratingBreakdown: [0.6, 0.2, 0.1, 0.06, 0.04],
    capabilities: [
      'Explain space science theories',
      'Solve physics problems step by step',
      'Summarise research papers',
    ],
    quickStarters: [
      'Explain black holes simply',
      'What is dark matter?',
      'How do rockets reach orbit?',
    ],
    filters: {PresetFilter.features, PresetFilter.education},
  );

  static const _gameSpace = Preset(
    id: 'game-space',
    name: 'Game Space World. AI Gaming',
    description: 'Ultimate gaming trick and tips for up to 200+ games',
    author: 'Minedrafter',
    image: AppAssets.presetGaming,
    rating: 2.5,
    category: 'Gaming',
    categoryRank: 7,
    siteUrl: 'https://store.steampowered.com',
    conversations: '+40K',
    reviews: 312,
    ratingBreakdown: [0.2, 0.15, 0.2, 0.25, 0.2],
    capabilities: [
      'Tricks and tips for 200+ games',
      'Build and loadout suggestions',
      'Walkthroughs for hard levels',
    ],
    quickStarters: [
      'Best starter build for Elden Ring',
      'Tips to rank up in Valorant',
      'Hidden secrets in Zelda',
    ],
    filters: {PresetFilter.trending, PresetFilter.features},
  );

  static const _repoExplainer = Preset(
    id: 'repo-explainer',
    name: 'GitHub - Repo Explainer',
    description: 'Ultimate AI for explanation of GitHub Repo & Code style',
    author: 'Kwaal Zyng',
    image: AppAssets.presetGithub,
    rating: 2.5,
    category: 'Coding & Programming',
    categoryRank: 12,
    siteUrl: 'https://github.com',
    conversations: '+65K',
    reviews: 644,
    ratingBreakdown: [0.3, 0.1, 0.25, 0.3, 0.05],
    capabilities: [
      'Read, Write, Replay Comments',
      'Manage Files',
      'Manage Team members',
    ],
    quickStarters: [
      'Explain me this module in this code',
      'Fork and summarise this repo',
      'Describe the code style used',
    ],
    filters: {PresetFilter.features, PresetFilter.business},
  );

  static const _prReviewer = Preset(
    id: 'pr-reviewer',
    name: 'GitHub - PR Reviewer',
    description: 'Reviews pull requests and suggests cleaner, safer changes',
    author: 'Kwaal Zyng',
    image: AppAssets.presetGithub,
    rating: 4.0,
    category: 'Coding & Programming',
    categoryRank: 15,
    siteUrl: 'https://github.com',
    conversations: '+32K',
    reviews: 288,
    ratingBreakdown: [0.45, 0.3, 0.15, 0.06, 0.04],
    capabilities: [
      'Review pull requests',
      'Suggest safer changes',
      'Flag missing tests',
    ],
    quickStarters: [
      'Review this pull request',
      'Find risky changes in this diff',
      'Suggest a cleaner refactor',
    ],
    filters: {PresetFilter.features, PresetFilter.business},
  );

  static const _musicZone = Preset(
    id: 'music-zone',
    name: 'Music Zone - All Modes',
    description: "Best Ai Space for Space science theory's and physics",
    author: 'Jacson Smith',
    image: AppAssets.presetSpace,
    rating: 4.5,
    category: 'Science & Education',
    categoryRank: 1,
    siteUrl: 'https://science.nasa.gov',
    conversations: '+210K',
    reviews: 2048,
    ratingBreakdown: [0.7, 0.18, 0.07, 0.03, 0.02],
    capabilities: [
      'Space science theory explained',
      'Physics made simple',
      'Study plans and quizzes',
    ],
    quickStarters: [
      'Explain general relativity',
      'Quiz me on astrophysics',
      'What is a neutron star?',
    ],
    filters: {PresetFilter.trending, PresetFilter.education},
  );

  /// Every preset, in catalogue order, for search and the filter chips.
  static const presets = [
    _spaceScience,
    _gameSpace,
    _repoExplainer,
    _prReviewer,
    _musicZone,
  ];

  /// The curated layout of the Hand Picked tab.
  static const groups = [
    PresetGroup(
      presets: [_spaceScience, _gameSpace],
      layout: PresetGroupLayout.tile,
    ),
    PresetGroup(
      titleKey: 'presets_section_coding',
      presets: [_repoExplainer, _prReviewer],
      layout: PresetGroupLayout.featured,
    ),
    PresetGroup(
      titleKey: 'presets_section_trending_week',
      presets: [_musicZone, _gameSpace],
      layout: PresetGroupLayout.ranked,
    ),
  ];

  /// True while a search or a chip other than Hand Picked narrows the list,
  /// in which case [results] replaces [groups].
  bool get isFiltering =>
      query.value.isNotEmpty || filter.value != PresetFilter.handPicked;

  /// Presets matching the search text and the selected chip.
  List<Preset> get results {
    final q = query.value;
    final f = filter.value;
    return [
      for (final preset in presets)
        if ((f == PresetFilter.handPicked || preset.filters.contains(f)) &&
            (q.isEmpty || preset.matches(q)))
          preset,
    ];
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => query.value = searchController.text.trim();

  void onFilter(PresetFilter value) => filter.value = value;

  /// Opens the detail screen; [heroTag] names the card that was tapped.
  void onPreset(Preset preset, String heroTag) => Get.toNamed(
    AppRoutes.presetDetail,
    arguments: PresetDetailArgs(preset: preset, heroTag: heroTag),
  );

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
