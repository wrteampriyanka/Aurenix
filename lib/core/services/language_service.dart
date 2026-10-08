import 'dart:ui';

import 'package:get/get.dart';

import 'package:aurenix/core/storage/storage_service.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// One of the languages the app can be shown in, picked from Profile.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.locale,
    required this.nameKey,
    required this.nativeName,
  });

  /// Matches the `assets/translations/<code>.json` file name.
  final String code;
  final Locale locale;

  /// Translation key for the name in the current language, e.g. "Hindi".
  final String nameKey;

  /// The name in its own language, e.g. "हिन्दी".
  final String nativeName;
}

/// Which language the app is shown in. The choice is kept across launches;
/// English is used until one is picked.
class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  static const english = AppLanguage(
    code: 'en_US',
    locale: Locale('en', 'US'),
    nameKey: AppStrings.languageEnglish,
    nativeName: 'English',
  );

  static const hindi = AppLanguage(
    code: 'hi_IN',
    locale: Locale('hi', 'IN'),
    nameKey: AppStrings.languageHindi,
    nativeName: 'हिन्दी',
  );

  static const arabic = AppLanguage(
    code: 'ar_SA',
    locale: Locale('ar', 'SA'),
    nameKey: AppStrings.languageArabic,
    nativeName: 'العربية',
  );

  static const languages = [english, hindi, arabic];

  static const fallback = english;

  /// The language in use.
  late final selected = _stored().obs;

  Locale get locale => selected.value.locale;

  static AppLanguage _stored() {
    final code = StorageService.instance.getString(StorageService.languageKey);
    return languages.firstWhereOrNull((l) => l.code == code) ?? fallback;
  }

  /// True while the app is being rebuilt for a new language.
  final switching = false.obs;

  /// Switches every screen to [language] and remembers it. Completes once
  /// the app has been rebuilt in the new language.
  Future<void> select(AppLanguage language) async {
    if (language == selected.value || switching.value) return;
    selected.value = language;
    switching.value = true;
    try {
      // Saved first: if the rebuild below throws, the choice is still the
      // one the user made rather than reverting on the next launch.
      await StorageService.instance.setString(
        StorageService.languageKey,
        language.code,
      );
      // Rebuilds every widget so each `.tr` string is re-resolved.
      await Get.updateLocale(language.locale);
    } finally {
      switching.value = false;
    }
  }
}
