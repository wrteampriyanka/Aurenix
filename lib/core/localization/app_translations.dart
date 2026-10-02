import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  AppTranslations._(this._keys);

  /// One entry per file in `assets/translations/`.
  static const List<String> _locales = ['en_US', 'hi_IN', 'ar_SA'];

  final Map<String, Map<String, String>> _keys;

  /// Loads every `assets/translations/<locale>.json` file into memory.
  static Future<AppTranslations> load() async {
    final keys = <String, Map<String, String>>{};
    for (final locale in _locales) {
      // Uncached, so a hot reload picks up edits to the JSON files.
      final raw = await rootBundle.loadString(
        'assets/translations/$locale.json',
        cache: false,
      );
      keys[locale] = Map<String, String>.from(jsonDecode(raw) as Map);
    }
    return AppTranslations._(keys);
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
