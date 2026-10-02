import 'dart:ui';

import 'package:get/get.dart';

import '../storage/storage_service.dart';

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
    nameKey: 'language_english',
    nativeName: 'English',
  );

  static const hindi = AppLanguage(
    code: 'hi_IN',
    locale: Locale('hi', 'IN'),
    nameKey: 'language_hindi',
    nativeName: 'हिन्दी',
  );

  static const arabic = AppLanguage(
    code: 'ar_SA',
    locale: Locale('ar', 'SA'),
    nameKey: 'language_arabic',
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
      // Rebuilds every widget so each `.tr` string is re-resolved.
      await Get.updateLocale(language.locale);
      await StorageService.instance.setString(
        StorageService.languageKey,
        language.code,
      );
    } finally {
      switching.value = false;
    }
  }
}
