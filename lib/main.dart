import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/bindings/initial_binding.dart';
import 'package:aurenix/core/constants/app_constants.dart';
import 'package:aurenix/core/localization/app_translations.dart';
import 'package:aurenix/core/routes/app_pages.dart';
import 'package:aurenix/core/services/chat_quota_service.dart';
import 'package:aurenix/core/services/language_service.dart';
import 'package:aurenix/core/storage/storage_service.dart';
import 'package:aurenix/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Anything the framework or the platform throws past a widget's own
  // handling. Without these a release build swallows it silently.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Uncaught Flutter error: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  await StorageService.instance.init();
  // Awaited: the quota is read from storage, and the first frame must not
  // see an empty allowance.
  await ChatQuotaService.instance.init();
  final translations = await AppTranslations.load();
  runApp(MyApp(translations: translations));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.translations});

  final AppTranslations translations;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// True while the translation files are being reloaded after a hot reload.
  bool _reloadingTranslations = false;

  /// Hot reload doesn't rerun [main], so reload the translation files here;
  /// otherwise newly added keys show up as raw keys until a full restart.
  ///
  /// [Get.forceAppUpdate] (used by [Get.updateLocale] when the language
  /// changes) also runs this, and the reload below ends with another
  /// [Get.forceAppUpdate], so it is guarded against re-entering itself.
  /// Without the guard every language change reassembled the app forever.
  @override
  void reassemble() {
    super.reassemble();
    if (!kDebugMode || _reloadingTranslations) return;
    _reloadingTranslations = true;
    AppTranslations.load()
        .then((translations) async {
          Get.clearTranslations();
          Get.addTranslations(translations.keys);
          await Get.forceAppUpdate();
        })
        .whenComplete(() => _reloadingTranslations = false);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // Dark-only: no darkTheme, and themeMode is pinned so nothing reads
      // the OS appearance setting.
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      translations: widget.translations,
      locale: LanguageService.instance.locale,
      fallbackLocale: LanguageService.fallback.locale,
      // Supplies WidgetsLocalizations (and so the text direction) for every
      // supported locale, plus Material's and Cupertino's own strings. Without
      // this Arabic falls back to DefaultWidgetsLocalizations and renders
      // left-to-right.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.languages.map((l) => l.locale),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
