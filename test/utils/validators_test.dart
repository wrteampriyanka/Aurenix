import 'package:flutter_test/flutter_test.dart';

import 'package:aurenix/utils/validators.dart';

/// The messages are translation keys. GetX returns the key itself when no
/// translations are loaded, which is what these expectations rely on.
void main() {
  group('Validators.required', () {
    test('rejects null, empty and whitespace', () {
      expect(Validators.required(null), 'validation_required');
      expect(Validators.required(''), 'validation_required');
      expect(Validators.required('   '), 'validation_required');
      expect(Validators.required('\n\t '), 'validation_required');
    });

    test('accepts anything with a character in it', () {
      expect(Validators.required('a'), isNull);
      expect(Validators.required('  padded  '), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects nothing at all', () {
      expect(Validators.email(null), 'validation_email_required');
      expect(Validators.email(''), 'validation_email_required');
    });

    test('accepts ordinary addresses', () {
      for (final address in [
        'a@b.co',
        'first.last@example.com',
        'user+tag@example.co.uk',
        'user_name@sub.example.org',
        'user-name@example.io',
      ]) {
        expect(Validators.email(address), isNull, reason: address);
      }
    });

    test('rejects malformed addresses', () {
      for (final address in [
        'plain',
        '@example.com',
        'user@',
        'user@example',
        'user @example.com',
        'user@exam ple.com',
      ]) {
        expect(
          Validators.email(address),
          'validation_email_invalid',
          reason: address,
        );
      }
    });

    test('whitespace is not trimmed, unlike required', () {
      expect(Validators.email('  a@b.co  '), 'validation_email_invalid');
    });
  });

  group('Validators.password', () {
    test('rejects nothing at all', () {
      expect(Validators.password(null), 'validation_password_required');
      expect(Validators.password(''), 'validation_password_required');
    });

    test('needs eight characters', () {
      expect(Validators.password('1234567'), 'validation_password_short');
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects nothing at all', () {
      expect(
        Validators.confirmPassword(null, 'secret123'),
        'validation_confirm_required',
      );
      expect(
        Validators.confirmPassword('', 'secret123'),
        'validation_confirm_required',
      );
    });

    test('must match exactly', () {
      expect(Validators.confirmPassword('secret123', 'secret123'), isNull);
      expect(
        Validators.confirmPassword('Secret123', 'secret123'),
        'validation_password_mismatch',
      );
      expect(
        Validators.confirmPassword('secret123 ', 'secret123'),
        'validation_password_mismatch',
      );
    });
  });
}
