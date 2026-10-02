import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/routes/app_routes.dart';
import '../../edit_profile/controllers/edit_profile_controller.dart';
import '../widgets/language_sheet.dart';

/// A row in one of the profile menu cards.
class ProfileMenuItem {
  const ProfileMenuItem(this.labelKey, this.icon);

  final String labelKey;
  final IconData icon;
}

class ProfileController extends GetxController {
  // TODO: replace with the signed-in user once auth is wired up.
  final userName = 'Mikel Strome'.obs;
  final userEmail = 'designer@gmail.com'.obs;
  String? genderKey = 'gender_male';
  int? age = 21;

  static const logout = ProfileMenuItem(
    'profile_logout',
    PhosphorIconsRegular.signOut,
  );

  static const archiveChats = ProfileMenuItem(
    'profile_archive_chats',
    PhosphorIconsRegular.arrowCircleDown,
  );

  static const customizeAi = ProfileMenuItem(
    'profile_customize_ai',
    PhosphorIconsRegular.slidersHorizontal,
  );

  static const dataControl = ProfileMenuItem(
    'profile_data_control',
    PhosphorIconsRegular.database,
  );

  static const privacyPolicy = ProfileMenuItem(
    'profile_privacy_policy',
    PhosphorIconsRegular.shieldCheck,
  );

  static const aboutUs = ProfileMenuItem(
    'profile_about_us',
    PhosphorIconsRegular.info,
  );

  static const connectedApps = ProfileMenuItem(
    'profile_connected_apps',
    PhosphorIconsRegular.puzzlePiece,
  );

  static const voiceSettings = ProfileMenuItem(
    'profile_voice_settings',
    PhosphorIconsRegular.waveform,
  );

  static const language = ProfileMenuItem(
    'profile_language',
    PhosphorIconsRegular.globe,
  );

  static const settingsItems = [
    customizeAi,
    archiveChats,
    language,
    voiceSettings,
    connectedApps,
  ];

  static const accountItems = [dataControl, privacyPolicy, aboutUs, logout];

  void onBack() => Get.back();

  void onNewChat() => Get.back();

  Future<void> onEditProfile() async {
    final result = await Get.toNamed(
      AppRoutes.editProfile,
      arguments: ProfileDetails(
        name: userName.value,
        email: userEmail.value,
        genderKey: genderKey,
        age: age,
      ),
    );
    if (result is! ProfileDetails) return;
    userName.value = result.name;
    userEmail.value = result.email;
    genderKey = result.genderKey;
    age = result.age;
  }

  void onUpgrade() => Get.toNamed(AppRoutes.upgrade);

  /// Lets them pick English, Hindi or Arabic; the sheet switches the app
  /// at once.
  Future<void> onLanguage() => LanguageSheet.show();

  // TODO: wire these up once the screens exist.
  void onModelTap() {}
  void onMore() {}

  void onItem(ProfileMenuItem item) {
    if (item == logout) Get.offAllNamed(AppRoutes.login);
    if (item == customizeAi) Get.toNamed(AppRoutes.customizeAi);
    if (item == archiveChats) Get.toNamed(AppRoutes.archiveChats);
    if (item == connectedApps) Get.toNamed(AppRoutes.connectedApps);
    if (item == voiceSettings) Get.toNamed(AppRoutes.voiceSettings);
    if (item == language) onLanguage();
    if (item == dataControl) Get.toNamed(AppRoutes.dataControl);
    if (item == privacyPolicy) Get.toNamed(AppRoutes.privacyPolicy);
    if (item == aboutUs) Get.toNamed(AppRoutes.aboutUs);
  }
}
