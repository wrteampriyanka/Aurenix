import 'package:get/get.dart';

import 'package:aurenix/core/theme/app_colors.dart';
import 'package:aurenix/features/collaboration/models/collaborator.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Stand-in collaborators until sharing exists.
///
/// TODO: delete this file once collaborators are loaded from the backend.
List<Collaborator> seededMembers() => <Collaborator>[
  Collaborator(
    id: 'm1',
    name: AppStrings.collaborationYou.tr,
    email: 'designer@gmail.com',
    initials: 'MS',
    color: appColors.avatarSwatch[0],
    role: CollaboratorRole.owner,
  ),
  Collaborator(
    id: 'm2',
    name: 'Alex',
    email: 'alaxy322@gmail.com',
    initials: 'AL',
    color: appColors.avatarSwatch[1],
    role: CollaboratorRole.viewOnly,
  ),
  Collaborator(
    id: 'm3',
    name: 'Rubina maria',
    email: 'rubbyspot443@gmail.com',
    initials: 'RM',
    color: appColors.avatarSwatch[2],
    role: CollaboratorRole.canEdit,
  ),
];
