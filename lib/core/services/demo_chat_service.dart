import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:aurenix/core/constants/app_assets.dart';

/// Who wrote a chat turn.
enum ChatRole { user, model }

/// One turn of the conversation.
class ChatTurn {
  const ChatTurn({
    required this.role,
    required this.text,
    this.file,
    this.mimeType = 'image/jpeg',
  });

  final ChatRole role;
  final String text;

  /// A file sent along with [text], e.g. a camera frame or a PDF.
  final Uint8List? file;

  /// Type of [file], e.g. `image/jpeg` or `application/pdf`.
  final String mimeType;
}

/// A picture made by [DemoChatService.generateImage].
class GeneratedImage {
  const GeneratedImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

/// What [DemoChatService.generateImage] returns: pictures plus any words.
class ImageReply {
  const ImageReply({required this.text, required this.images});

  final String text;
  final List<GeneratedImage> images;
}

/// A web page a reply was grounded on.
class ChatSource {
  const ChatSource({required this.title, required this.uri});

  /// Usually the site's domain, e.g. "nasa.gov".
  final String title;
  final String uri;
}

/// One streamed piece of a reply.
class ChatChunk {
  const ChatChunk({this.text = '', this.sources = const []});

  final String text;
  final List<ChatSource> sources;
}

/// Thrown when a reply cannot be built.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Canned replies for the demo build.
///
/// There is no AI provider behind the chat: every answer below is written
/// here and typed out on a timer, so the screens can be shown without a
/// key, a network or an error strip.
class DemoChatService {
  DemoChatService._();

  static final DemoChatService instance = DemoChatService._();

  /// Pause between words while a reply types itself out.
  static const _wordDelay = Duration(milliseconds: 35);

  /// Wait before the first words arrive, so "Thinking" is readable.
  static const _thinkDelay = Duration(milliseconds: 600);

  /// How long a picture takes to "draw".
  static const _drawDelay = Duration(milliseconds: 1800);

  /// Pictures handed back for a "Generate image" reply, in order: the
  /// first ask gets the first one, the next ask the one after it.
  static const _imageAssets = [
    AppAssets.presetSpace,
    AppAssets.presetGaming,
    AppAssets.presetGithub,
  ];

  /// Lines said under each picture, paired with [_imageAssets].
  static const _imageReplies = [
    'Here is the image you asked for.\n\n'
        'If you have any question about planet feel free to ask.',
    'Done, I added that to the picture.\n\n'
        'Want me to change the colours or the mood of the scene?',
    'Here is another take on it.\n\n'
        'Tell me what to add next and I will draw it in.',
  ];

  /// Counts the pictures drawn so far, so each ask gets a new one.
  int _imagesDrawn = 0;

  /// Whether the message should be answered with a picture: the user
  /// asked to draw something, or sent a photo to change.
  static bool wantsImage(String text, {bool hasImage = false}) {
    if (hasImage) return true;
    const words = [
      'image',
      'picture',
      'photo',
      'draw',
      'paint',
      'generate',
      'create an',
      'add ',
    ];
    final lower = text.toLowerCase();
    return words.any(lower.contains);
  }

  /// Types out the answer to [history] (oldest first, ending with the
  /// user's message) word by word.
  Stream<ChatChunk> streamChat(
    List<ChatTurn> history, {
    bool searchWeb = false,
    String? instruction,
  }) async* {
    final last = history.lastWhere(
      (turn) => turn.role == ChatRole.user,
      orElse: () => const ChatTurn(role: ChatRole.user, text: ''),
    );
    final answer = _answerFor(
      last.text,
      hasFile: last.file != null,
      isCode: instruction != null,
      searchWeb: searchWeb,
    );

    await Future<void>.delayed(_thinkDelay);
    for (final word in _words(answer)) {
      await Future<void>.delayed(_wordDelay);
      yield ChatChunk(text: word);
    }
    if (searchWeb) yield const ChatChunk(sources: _demoSources);
  }

  /// Hands back a picture from the assets for the last message, which may
  /// carry a photo the user wants changed.
  Future<ImageReply> generateImage(List<ChatTurn> history) async {
    await Future<void>.delayed(_drawDelay);
    final index = _imagesDrawn++ % _imageAssets.length;
    final data = await rootBundle.load(_imageAssets[index]);
    return ImageReply(
      text: _imageReplies[index],
      images: [
        GeneratedImage(
          bytes: data.buffer.asUint8List(),
          mimeType: _imageAssets[index].endsWith('.jpg')
              ? 'image/jpeg'
              : 'image/png',
        ),
      ],
    );
  }

  /// Splits [text] so each piece carries its trailing space, which keeps
  /// the words apart as they are added one by one.
  static List<String> _words(String text) => [
    for (final word in text.split(' ')) '$word ',
  ];

  /// The canned answer for what the user just said.
  static String _answerFor(
    String text, {
    required bool hasFile,
    required bool isCode,
    required bool searchWeb,
  }) {
    final lower = text.toLowerCase().trim();
    if (isCode) return _codeAnswer;
    if (searchWeb) return _researchAnswer;
    if (hasFile) return _fileAnswer;
    if (lower.isEmpty) return _defaultAnswer;
    if (RegExp(r'\b(hi|hello|hey|good morning|good evening)\b')
        .hasMatch(lower)) {
      return _greetingAnswer;
    }
    if (lower.contains('who are you') || lower.contains('your name')) {
      return _aboutAnswer;
    }
    if (lower.contains('how are you')) return _howAreYouAnswer;
    if (lower.contains('?')) return _questionAnswer;
    return _defaultAnswer;
  }

  static const _greetingAnswer =
      'Hey, good to see you. I am **Aurenix**, your assistant in this app.\n\n'
      'I can write for you, explain things, draw a picture or look something '
      'up.\n\nWhat would you like to start with?';

  static const _aboutAnswer =
      'I am **Aurenix**, the assistant built into this app.\n\n'
      '- I answer questions and write text for you\n'
      '- I draw pictures from a description\n'
      '- I read the photos and documents you send\n\n'
      'What shall we work on first?';

  static const _howAreYouAnswer =
      'Doing well, thanks for asking, and ready to work.\n\n'
      'What is on your mind today?';

  static const _questionAnswer =
      'Good question. Here is the short answer:\n\n'
      '- It comes down to **what you want the result to do**\n'
      '- Start with the simplest version that works\n'
      '- Then add only what you actually miss\n\n'
      'Do you want me to go deeper on any of those three points?';

  static const _fileAnswer =
      'Thanks, I had a look at what you sent.\n\n'
      '- The main subject is clear and well lit\n'
      '- The colours lean warm, which suits the mood\n'
      '- There is room at the edges if you want to add something\n\n'
      'Shall I change anything in it for you?';

  static const _researchAnswer =
      'Here is what I found on that:\n\n'
      '- The idea has been around for a while and is well documented\n'
      '- Most guides agree on the basics, they differ on the details\n'
      '- The newest write-ups add a few practical examples\n\n'
      'Want me to summarise one of the sources below?';

  static const _codeAnswer =
      'Here is a small example:\n\n'
      '```dart\n'
      'void main() {\n'
      "  final items = ['one', 'two', 'three'];\n"
      '  for (final (i, item) in items.indexed) {\n'
      "    print('\${i + 1}. \$item');\n"
      '  }\n'
      '}\n'
      '```\n\n'
      'It walks the list with `indexed` so you get the position along with '
      'the value, then prints a numbered line for each one. Run it with '
      '`dart run`.\n\n'
      'Want it in another language?';

  static const _defaultAnswer =
      'Got it. Here is how I would approach that:\n\n'
      '1. **Be clear on the goal** so the result has something to aim at\n'
      '2. **Keep the first version small**, it is easier to judge\n'
      '3. **Change one thing at a time** and keep what works\n\n'
      'Tell me a bit more and I will make this specific to your case.';

  static const _demoSources = [
    ChatSource(title: 'wikipedia.org', uri: 'https://www.wikipedia.org'),
    ChatSource(title: 'nasa.gov', uri: 'https://www.nasa.gov'),
    ChatSource(title: 'nature.com', uri: 'https://www.nature.com'),
  ];
}
