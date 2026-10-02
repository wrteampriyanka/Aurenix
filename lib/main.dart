import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/app_translations.dart';
import 'core/routes/app_pages.dart';
import 'core/services/language_service.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
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
  /// Hot reload doesn't rerun [main], so reload the translation files here;
  /// otherwise newly added keys show up as raw keys until a full restart.
  @override
  void reassemble() {
    super.reassemble();
    AppTranslations.load().then((translations) {
      Get.clearTranslations();
      Get.addTranslations(translations.keys);
      Get.forceAppUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: widget.translations,
      locale: LanguageService.instance.locale,
      fallbackLocale: LanguageService.fallback.locale,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
