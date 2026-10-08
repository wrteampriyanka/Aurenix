import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/features/home/models/chat_summary.dart';
import 'package:aurenix/features/home/models/project.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Stand-in content for the sidebar until the API can serve it.
///
/// TODO: delete this file once projects, chats and transcripts are loaded
/// from the backend.
// NOTE: three of the icon tints below (F43F5E, 3B82F6, F59E0B) are not in
// [AppColors.projectIconSwatch], so the create-project sheet cannot offer
// them. Either add them to the swatch or reseed from it — a design call.
List<Project> seededProjects() => <Project>[
  Project(
    id: 'p1',
    name: AppStrings.sidebarResearch.tr,
    icon: PhosphorIconsRegular.lightbulb,
    iconColor: const Color(0xFFFACC15),
    chatCount: 32,
  ),
  Project(
    id: 'p2',
    name: AppStrings.sidebarEducation.tr,
    icon: PhosphorIconsRegular.bookOpen,
    iconColor: const Color(0xFFF43F5E),
    chatCount: 16,
  ),
  const Project(
    id: 'p3',
    name: 'Business',
    icon: PhosphorIconsRegular.monitor,
    iconColor: Color(0xFF3B82F6),
    chatCount: 43,
  ),
  const Project(
    id: 'p4',
    name: 'My Ideas',
    icon: PhosphorIconsRegular.lightning,
    iconColor: Color(0xFFF59E0B),
    chatCount: 23,
  ),
];

// TODO: load the user's chats and profile once the API exists.
List<ChatSummary> seededChats() => <ChatSummary>[
  const ChatSummary(id: '1', title: 'Multiverse & Cosmic Power'),
  const ChatSummary(id: '2', title: 'Incursion of tow universes'),
  const ChatSummary(id: '3', title: 'Astral travel & Subconscious'),
];

// TODO: drop these along with the seeded chats above once the API can
// hand back real conversations.
const demoTranscripts = {
  '1': [
    'Could several universes really hold different laws of physics?',
    'They could. In the inflationary picture each bubble universe cools '
        'into its own vacuum state, so constants we treat as fixed — the '
        'strength of gravity, the mass of an electron — settle at '
        'different values in each one. Most of those settings would never '
        'form stars or chemistry, which is why ours looks finely tuned '
        'from the inside.',
    'So where would the cosmic power in those stories come from?',
    'In fiction it is usually borrowed from the vacuum itself: the energy '
        'of empty space, which really is what drives the expansion we '
        'measure. The leap is the idea that a being could tap it locally '
        'and keep the result stable.',
  ],
  '2': [
    'What would actually happen if two universes touched?',
    'If two bubbles with different vacuum states met, the wall between '
        'them would not stay put — the lower-energy vacuum would eat into '
        'the higher one at close to the speed of light, rewriting the '
        'physics inside as it went. Nothing built out of the old constants '
        'would survive the crossing.',
    'That is grimmer than the comics make it look.',
    'Much grimmer. The comic version keeps both sets of matter intact so '
        'the characters can meet, which needs the walls to be stable — the '
        'one thing the physics does not give you.',
  ],
  '3': [
    'Is there any evidence for astral travel, or is it all subconscious?',
    'The experiences are real and well documented; the travel is not. '
        'Out-of-body episodes can be brought on in a lab by stimulating '
        'the temporoparietal junction, which is where the brain stitches '
        'touch, balance and vision into one sense of where you are. '
        'Disturb that and the self seems to sit outside the body.',
    'Why do the reports agree with each other so often?',
    'Because they come from the same machinery: the ceiling view, the '
        'floating, the tunnel all follow from how that region fails. '
        'Shared anatomy gives shared imagery without a shared destination.',
  ],
};

/// The project screen lists the same three conversations under its own
/// ids, so they open to the same words.
const demoAliases = {'pc1': '1', 'pc2': '2', 'pc3': '3'};
