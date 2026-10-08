import 'package:get/get.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// An app card on the integration screen.
class IntegrationApp {
  const IntegrationApp({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.logo,
    required this.handle,
    required this.permissionKeys,
    this.tintLogo = false,
  });

  final String id;
  final String nameKey;
  final String descriptionKey;

  /// Account or API the app is reached through, shown in the info sheet.
  final String handle;

  /// Translation keys of the permissions listed in the info sheet.
  final List<String> permissionKeys;

  /// SVG or PNG asset.
  final String logo;

  /// Draws [logo] in the text colour, for logos too dark for the card.
  final bool tintLogo;
}

/// Holds the integration catalog and which apps the user has connected.
///
/// Kept alive for the whole session so the connected apps survive leaving
/// the integration screen, and the home + sheet can list them too.
class ConnectedAppsService extends GetxService {
  static ConnectedAppsService get to => Get.isRegistered<ConnectedAppsService>()
      ? Get.find<ConnectedAppsService>()
      : Get.put(ConnectedAppsService(), permanent: true);

  static const apps = [
    IntegrationApp(
      id: 'figma',
      nameKey: AppStrings.servicesFigma,
      descriptionKey: 'services_figma_desc',
      logo: AppAssets.figmaColorLogo,
      handle: '@figma-automation-api',
      permissionKeys: [
        'app_info_perm_comments',
        'app_info_perm_files',
        'app_info_perm_team',
      ],
    ),
    IntegrationApp(
      id: 'zync',
      nameKey: AppStrings.servicesZync,
      descriptionKey: 'services_zync_desc',
      logo: AppAssets.zyncLogo,
      handle: '@zync-workspace',
      permissionKeys: [
        'app_info_perm_messages',
        'app_info_perm_comments',
        'app_info_perm_canvas',
      ],
    ),
    IntegrationApp(
      id: 'google_drive',
      nameKey: AppStrings.servicesGoogleDrive,
      descriptionKey: 'services_google_drive_desc',
      logo: AppAssets.googleDriveLogo,
      handle: '@google-drive-api',
      permissionKeys: [
        'app_info_perm_files',
        'app_info_perm_folders',
        'app_info_perm_sharing',
      ],
    ),
    IntegrationApp(
      id: 'notion',
      nameKey: AppStrings.connectedAppsNotion,
      descriptionKey: 'connected_apps_notion_desc',
      logo: AppAssets.notionLogo,
      handle: '@notion-ai-remote',
      permissionKeys: [
        'app_info_perm_comments',
        'app_info_perm_pages',
        'app_info_perm_activity',
        'app_info_perm_database',
      ],
    ),
    IntegrationApp(
      id: 'firebase',
      nameKey: AppStrings.connectedAppsFirebase,
      descriptionKey: 'connected_apps_firebase_desc',
      logo: AppAssets.firebaseLogo,
      handle: '@firebase-admin-sdk',
      permissionKeys: [
        'app_info_perm_push',
        'app_info_perm_auth',
        'app_info_perm_content',
      ],
    ),
    IntegrationApp(
      id: 'slack',
      nameKey: AppStrings.connectedAppsSlack,
      descriptionKey: 'connected_apps_slack_desc',
      logo: AppAssets.slackLogo,
      handle: '@slack-bot-api',
      permissionKeys: [
        'app_info_perm_messages',
        'app_info_perm_reply',
        'app_info_perm_schedule',
      ],
    ),
    IntegrationApp(
      id: 'teams',
      nameKey: AppStrings.connectedAppsTeams,
      descriptionKey: 'connected_apps_teams_desc',
      logo: AppAssets.teamsLogo,
      handle: '@teams-graph-api',
      permissionKeys: [
        'app_info_perm_chat',
        'app_info_perm_meetings',
        'app_info_perm_auto_reply',
      ],
    ),
    IntegrationApp(
      id: 'gitlab',
      nameKey: AppStrings.connectedAppsGitlab,
      descriptionKey: 'connected_apps_gitlab_desc',
      logo: AppAssets.gitlabLogo,
      handle: '@gitlab-api',
      permissionKeys: [
        'app_info_perm_projects',
        'app_info_perm_tasks',
        'app_info_perm_reports',
      ],
    ),
    IntegrationApp(
      id: 'github',
      nameKey: AppStrings.connectedAppsGithub,
      descriptionKey: 'connected_apps_github_desc',
      logo: AppAssets.githubLogo,
      handle: '@github-app',
      permissionKeys: [
        'app_info_perm_code',
        'app_info_perm_projects',
        'app_info_perm_pr_review',
      ],
      tintLogo: true,
    ),
  ];

  // TODO: load the user's connected apps once the API exists.
  final connectedIds = <String>{'figma', 'zync', 'google_drive'}.obs;

  bool isConnected(IntegrationApp app) => connectedIds.contains(app.id);

  /// Connected apps, in catalog order.
  List<IntegrationApp> get connectedApps => apps.where(isConnected).toList();

  // TODO: run the app's OAuth flow / revoke its token once the API exists.
  void setConnected(IntegrationApp app, bool connected) =>
      connected ? connectedIds.add(app.id) : connectedIds.remove(app.id);
}
