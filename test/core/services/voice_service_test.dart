import 'package:flutter_test/flutter_test.dart';

import 'package:aurenix/core/services/voice_service.dart';

void main() {
  group('VoiceService.speechParts', () {
    test('short text comes back as one part', () {
      expect(VoiceService.speechParts('Hello there.'), ['Hello there.']);
    });

    test('empty and blank text produce nothing to say', () {
      expect(VoiceService.speechParts(''), isEmpty);
      expect(VoiceService.speechParts('   '), isEmpty);
    });

    test('splits on sentence ends only when over the limit', () {
      const two = 'One. Two.';
      expect(VoiceService.speechParts(two), [two]);
      expect(VoiceService.speechParts(two, maxLength: 5), ['One.', 'Two.']);
    });

    test('every part stays within maxLength', () {
      final text = List.filled(60, 'Sentence number one.').join(' ');
      final parts = VoiceService.speechParts(text, maxLength: 100);
      expect(parts, isNotEmpty);
      for (final part in parts) {
        expect(part.length, lessThanOrEqualTo(100));
      }
    });

    test('a single sentence longer than the limit is cut up', () {
      final long = 'a' * 250;
      final parts = VoiceService.speechParts(long, maxLength: 100);
      expect(parts.length, 3);
      expect(parts.map((p) => p.length), [100, 100, 50]);
      expect(parts.join(), long);
    });

    test('no words are lost', () {
      const text = 'First sentence. Second one! Third? And a fourth.';
      final joined = VoiceService.speechParts(text, maxLength: 20).join(' ');
      expect(joined.replaceAll(RegExp(r'\s+'), ' '), text);
    });

    // The split is `(?<=[.!?\n])\s+`, so a break needs whitespace *after*
    // the newline. A blank line between paragraphs splits; a single newline
    // runs the two lines together and is only broken by maxLength.
    test('a blank line is a sentence end', () {
      expect(
        VoiceService.speechParts('Line one\n\nLine two', maxLength: 10),
        // The newline stays on the part it ended; only the blank line goes.
        ['Line one\n', 'Line two'],
      );
    });

    test('a single newline is not a sentence end', () {
      expect(VoiceService.speechParts('Line one\nLine two'), [
        'Line one\nLine two',
      ]);
    });
  });

  group('VoiceService.plainText', () {
    test('keeps the words of a link and drops the target', () {
      expect(
        VoiceService.plainText('See [the docs](https://example.com) now'),
        'See the docs now',
      );
    });

    test('strips emphasis, headings and code marks', () {
      expect(
        VoiceService.plainText('**bold** and _italic_'),
        'bold and italic',
      );
      expect(VoiceService.plainText('# Heading'), 'Heading');
      expect(VoiceService.plainText('`code`'), 'code');
      expect(VoiceService.plainText('> quoted'), 'quoted');
    });

    test('strips list bullets at the start of a line', () {
      expect(VoiceService.plainText('- one\n- two'), 'one\ntwo');
      expect(VoiceService.plainText('+ one\n+ two'), 'one\ntwo');
    });

    test('trims the result', () {
      expect(VoiceService.plainText('  spaced  '), 'spaced');
    });

    test('leaves ordinary prose alone', () {
      const prose = 'Saturn is about 9.14 times larger than Earth.';
      expect(VoiceService.plainText(prose), prose);
    });
  });

  group('VoiceService.voices', () {
    test('ids are unique, so a saved choice resolves to one voice', () {
      final ids = VoiceService.voices.map((v) => v.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('there is at least one of each gender to assign', () {
      expect(VoiceService.voices.any((v) => v.isMale), isTrue);
      expect(VoiceService.voices.any((v) => !v.isMale), isTrue);
    });

    test('pitch and rate stay in the range the engines accept', () {
      for (final voice in VoiceService.voices) {
        expect(voice.pitch, inInclusiveRange(0.5, 2.0), reason: voice.id);
        expect(
          voice.fallbackPitch,
          inInclusiveRange(0.5, 2.0),
          reason: voice.id,
        );
        expect(voice.rate, inInclusiveRange(0.0, 1.0), reason: voice.id);
      }
    });
  });
}
