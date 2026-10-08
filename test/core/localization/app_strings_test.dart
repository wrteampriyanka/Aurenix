import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads the constant *values* out of app_strings.dart. Reflection is not
/// available here, and the file is generated from the JSON anyway, so the
/// source is the thing to check.
Set<String> _constantValues() {
  final source = File('lib/core/constants/app_strings.dart').readAsStringSync();
  // `dart format` wraps the long ones onto a second line, so allow
  // whitespace between the `=` and the value.
  return RegExp(r"static const \w+ =\s+'([a-z0-9_]+)';")
      .allMatches(source)
      .map((m) => m[1]!)
      .toSet();
}

Set<String> _jsonKeys() => (jsonDecode(
  File('assets/translations/en_US.json').readAsStringSync(),
) as Map<String, dynamic>).keys.toSet();

void main() {
  test('AppStrings covers every key in the translation files', () {
    expect(
      _jsonKeys().difference(_constantValues()),
      isEmpty,
      reason: 'add these to AppStrings',
    );
  });

  test('AppStrings has no key the translation files do not', () {
    expect(
      _constantValues().difference(_jsonKeys()),
      isEmpty,
      reason: 'these constants point at nothing',
    );
  });

  test('no constant name is reused', () {
    final source = File('lib/core/constants/app_strings.dart')
        .readAsStringSync();
    final names = RegExp(r'static const (\w+) =')
        .allMatches(source)
        .map((m) => m[1]!)
        .toList();
    expect(names.toSet().length, names.length);
  });

  test('lib/ has no raw translation key left outside AppStrings', () {
    final offenders = <String>[];
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      if (file.path.endsWith('app_strings.dart')) continue;
      final source = file.readAsStringSync();
      for (final m in RegExp(
        r"'([a-z0-9_]+)'\.(?:tr|trParams|trArgs)\b",
      ).allMatches(source)) {
        offenders.add('${file.path}: ${m[1]}');
      }
    }
    expect(offenders, isEmpty, reason: 'use AppStrings for these');
  });
}
