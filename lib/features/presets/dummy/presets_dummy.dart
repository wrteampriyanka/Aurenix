import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/features/presets/models/preset_group.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Stand-in preset catalogue until the API can serve it.
///
/// TODO: delete this file once presets are loaded from the backend.
const _spaceScience = Preset(
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

const _gameSpace = Preset(
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

const _repoExplainer = Preset(
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

const _prReviewer = Preset(
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

const _musicZone = Preset(
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
const presets = [
  _spaceScience,
  _gameSpace,
  _repoExplainer,
  _prReviewer,
  _musicZone,
];

/// The curated layout of the Hand Picked tab.
const groups = [
  PresetGroup(
    presets: [_spaceScience, _gameSpace],
    layout: PresetGroupLayout.tile,
  ),
  PresetGroup(
    titleKey: AppStrings.presetsSectionCoding,
    presets: [_repoExplainer, _prReviewer],
    layout: PresetGroupLayout.featured,
  ),
  PresetGroup(
    titleKey: AppStrings.presetsSectionTrendingWeek,
    presets: [_musicZone, _gameSpace],
    layout: PresetGroupLayout.ranked,
  ),
];
