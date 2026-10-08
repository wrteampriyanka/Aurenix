import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads the JSON straight off disk rather than through [rootBundle]: this
/// is about the files themselves, and it keeps the test out of a widget
/// binding.
Map<String, dynamic> _load(String locale) =>
    jsonDecode(File('assets/translations/$locale.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const locales = ['en_US', 'hi_IN', 'ar_SA'];
  const reference = 'en_US';

  late Map<String, Map<String, dynamic>> byLocale;

  setUpAll(() {
    byLocale = {for (final l in locales) l: _load(l)};
  });

  test('every locale file is registered in AppTranslations', () {
    final onDisk = Directory('assets/translations')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''))
        .toSet();
    expect(onDisk, locales.toSet());
  });

  test('every locale has exactly the same keys', () {
    final expected = byLocale[reference]!.keys.toSet();
    for (final locale in locales) {
      final actual = byLocale[locale]!.keys.toSet();
      expect(
        actual.difference(expected),
        isEmpty,
        reason: '$locale has keys $reference does not',
      );
      expect(
        expected.difference(actual),
        isEmpty,
        reason: '$locale is missing keys',
      );
    }
  });

  test('no value is empty', () {
    for (final locale in locales) {
      byLocale[locale]!.forEach((key, value) {
        expect(value, isA<String>(), reason: '$locale/$key is not a string');
        expect(
          (value as String).trim(),
          isNotEmpty,
          reason: '$locale/$key is blank',
        );
      });
    }
  });

  test('placeholders match across locales', () {
    final placeholder = RegExp(r'@\w+');
    byLocale[reference]!.forEach((key, value) {
      final expected = placeholder
          .allMatches(value as String)
          .map((m) => m[0])
          .toSet();
      for (final locale in locales.where((l) => l != reference)) {
        final actual = placeholder
            .allMatches(byLocale[locale]![key] as String)
            .map((m) => m[0])
            .toSet();
        expect(
          actual,
          expected,
          reason: '$locale/$key has different placeholders',
        );
      }
    });
  });

  test('no duplicate keys slipped into a file', () {
    for (final locale in locales) {
      final raw = File('assets/translations/$locale.json').readAsStringSync();
      final declared = RegExp(
        r'^\s*"([^"]+)"\s*:',
        multiLine: true,
      ).allMatches(raw).map((m) => m[1]!).toList();
      final seen = <String>{};
      final duplicates = declared.where((k) => !seen.add(k)).toList();
      expect(duplicates, isEmpty, reason: '$locale repeats these keys');
    }
  });
}
