import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/session_service.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/language_sheet.dart';
import 'package:aurenix/features/edit_profile/models/profile_details.dart';
import 'package:aurenix/features/profile/models/profile_menu_item.dart';

class ProfileController extends GetxController {
  // TODO: replace with the signed-in user once auth is wired up.
  final userName = 'Mikel Strome'.obs;
  final userEmail = 'designer@gmail.com'.obs;
  String? genderKey = 'gender_male';
  int? age = 21;

  static const logout = ProfileMenuItem(
    'profile_logout',
    PhosphorIconsRegular.door,
  );

  static const archiveChats = ProfileMenuItem(
    'profile_archive_chats',
    PhosphorIconsRegular.arrowCircleDown,
  );

  static const customizeAi = ProfileMenuItem(
    'profile_customize_ai',
    PhosphorIconsRegular.fadersHorizontal,
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
    PhosphorIconsRegular.globeHemisphereWest,
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
  void onMore(Rect anchor) {}

  /// Drops the saved session, so the next launch starts at sign in.
  Future<void> _logout() async {
    await SessionService.instance.signOut();
    unawaited(Get.offAllNamed(AppRoutes.login));
  }

  void onItem(ProfileMenuItem item) {
    if (item == logout) _logout();
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
