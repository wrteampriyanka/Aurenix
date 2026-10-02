import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Who wrote a chat turn, in Gemini's terms.
enum ChatRole { user, model }

/// One turn of the conversation sent to the AI.
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

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'parts': [
      if (file != null)
        {
          'inline_data': {'mime_type': mimeType, 'data': base64Encode(file!)},
        },
      if (text.isNotEmpty || file == null) {'text': text},
    ],
  };
}

/// A picture made by [ApiService.generateImage].
class GeneratedImage {
  const GeneratedImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

/// What [ApiService.generateImage] returns: pictures plus any words.
class ImageReply {
  const ImageReply({required this.text, required this.images});

  final String text;
  final List<GeneratedImage> images;
}

/// A web page Gemini used to ground its answer.
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

/// Thrown when the AI request fails or the key is missing.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Central place for network calls.
///
/// The AI chat uses Google AI Studio's Gemini API. The key is read at build
/// time from `.env` (gitignored), never from source:
/// ```
/// flutter run --dart-define-from-file=.env
/// ```
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Any model from https://ai.google.dev/gemini-api/docs/models.
  static const model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.5-flash',
  );

  /// Model used for "Generate image", one that can output pictures.
  static const imageModel = String.fromEnvironment(
    'GEMINI_IMAGE_MODEL',
    defaultValue: 'gemini-2.5-flash-image',
  );

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt =
      'You are Aurenix, a friendly and helpful AI assistant. '
      'Answer clearly and concisely. Use Markdown (short paragraphs, '
      'bullet lists, bold) when it helps readability.';

  final _client = http.Client();

  bool get hasApiKey => _apiKey.isNotEmpty;

  static const _missingKey = ApiException(
    'Missing Gemini API key. Add GEMINI_API_KEY to .env and run with '
    '--dart-define-from-file=.env',
  );

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-goog-api-key': _apiKey,
  };

  /// Streams the reply to [history] (oldest first, ending with the user's
  /// message) as chunks. With [searchWeb] Gemini may ground the answer
  /// with Google Search, and the chunks carry the pages it used.
  /// [instruction] is added to the system prompt, e.g. to ask for code.
  Stream<ChatChunk> streamChat(
    List<ChatTurn> history, {
    bool searchWeb = false,
    String? instruction,
  }) async* {
    if (!hasApiKey) throw _missingKey;

    final request =
        http.Request(
            'POST',
            Uri.parse('$_baseUrl/$model:streamGenerateContent?alt=sse'),
          )
          ..headers.addAll(_headers)
          ..body = jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': _systemPrompt},
                if (instruction != null) {'text': instruction},
              ],
            },
            'contents': [for (final turn in history) turn.toJson()],
            if (searchWeb)
              'tools': [
                {'google_search': <String, dynamic>{}},
              ],
          });

    final response = await _client.send(request);
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw ApiException(_errorMessage(response.statusCode, body));
    }

    // Server-sent events: each `data:` line holds one JSON chunk.
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final json = jsonDecode(line.substring(5)) as Map<String, dynamic>;
      final chunk = ChatChunk(text: _textOf(json), sources: _sourcesOf(json));
      if (chunk.text.isNotEmpty || chunk.sources.isNotEmpty) yield chunk;
    }
  }

  /// Draws a picture for the last message in [history], which may carry a
  /// photo to edit.
  Future<ImageReply> generateImage(List<ChatTurn> history) async {
    if (!hasApiKey) throw _missingKey;
    final response = await _client.post(
      Uri.parse('$_baseUrl/$imageModel:generateContent'),
      headers: _headers,
      body: jsonEncode({
        'contents': [for (final turn in history) turn.toJson()],
        'generationConfig': {
          'responseModalities': ['TEXT', 'IMAGE'],
        },
      }),
    );
    if (response.statusCode != 200) {
      throw ApiException(_errorMessage(response.statusCode, response.body));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    final parts = candidates == null || candidates.isEmpty
        ? const []
        : (candidates.first['content']?['parts'] as List?) ?? const [];
    final images = <GeneratedImage>[];
    for (final part in parts) {
      final inline = part['inlineData'] ?? part['inline_data'];
      if (inline is! Map || inline['data'] is! String) continue;
      images.add(
        GeneratedImage(
          bytes: base64Decode(inline['data'] as String),
          mimeType:
              (inline['mimeType'] ?? inline['mime_type'] ?? 'image/png')
                  as String,
        ),
      );
    }
    if (images.isEmpty && _textOf(json).isEmpty) {
      throw const ApiException('No image came back, try another prompt.');
    }
    return ImageReply(text: _textOf(json), images: images);
  }

  static String _textOf(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return '';
    final parts = (candidates.first['content']?['parts'] as List?) ?? [];
    return parts
        .where((p) => p['thought'] != true)
        .map((p) => p['text'] ?? '')
        .join();
  }

  static List<ChatSource> _sourcesOf(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return const [];
    final chunks =
        (candidates.first['groundingMetadata']?['groundingChunks'] as List?) ??
        [];
    return [
      for (final chunk in chunks)
        if (chunk['web'] case {'uri': final String uri} && final web)
          ChatSource(title: (web['title'] as String?) ?? uri, uri: uri),
    ];
  }

  static String _errorMessage(int status, String body) {
    switch (status) {
      case 429:
        return 'Free tier limit reached, please try again in a minute.';
      case 503:
        return 'The model is busy right now, please try again shortly.';
    }
    try {
      return jsonDecode(body)['error']['message'] as String;
    } catch (_) {
      return 'Request failed ($status).';
    }
  }
}
