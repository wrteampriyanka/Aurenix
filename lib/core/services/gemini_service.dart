import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Who wrote a turn, in Gemini's terms.
enum GeminiRole { user, model }

/// One turn of the conversation sent to Gemini.
class GeminiTurn {
  const GeminiTurn({required this.role, required this.text});

  final GeminiRole role;
  final String text;

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'parts': [
      {'text': text},
    ],
  };
}

/// Thrown when Gemini returns an error or the key is missing.
class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Chat with Google AI Studio's Gemini API (free tier works).
///
/// Pass the key at build time, never commit it:
/// ```
/// flutter run --dart-define=GEMINI_API_KEY=your_key
/// flutter run --dart-define-from-file=env.json
/// ```
class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Any model from https://ai.google.dev/gemini-api/docs/models.
  static const model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-flash-latest',
  );

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt =
      'You are Aurenix, a friendly and helpful AI assistant. '
      'Answer clearly and concisely. Use Markdown (short paragraphs, '
      'bullet lists, bold) when it helps readability.';

  final _client = http.Client();

  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Streams the reply to [history] (oldest first, ending with the user's
  /// message) as text chunks. With [searchWeb] Gemini may ground the answer
  /// with Google Search.
  Stream<String> streamReply(
    List<GeminiTurn> history, {
    bool searchWeb = false,
  }) async* {
    if (!hasApiKey) {
      throw const GeminiException(
        'Missing Gemini API key. Run the app with '
        '--dart-define=GEMINI_API_KEY=<your key> '
        '(get one free at aistudio.google.com/apikey).',
      );
    }

    final request =
        http.Request(
            'POST',
            Uri.parse('$_baseUrl/$model:streamGenerateContent?alt=sse'),
          )
          ..headers.addAll({
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          })
          ..body = jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': _systemPrompt},
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
      throw GeminiException(_errorMessage(response.statusCode, body));
    }

    // Server-sent events: each `data:` line holds one JSON chunk.
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final json = jsonDecode(line.substring(5)) as Map<String, dynamic>;
      final text = _textOf(json);
      if (text.isNotEmpty) yield text;
    }
  }

  static String _textOf(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return '';
    final parts = (candidates.first['content']?['parts'] as List?) ?? [];
    return parts.map((p) => p['text'] ?? '').join();
  }

  static String _errorMessage(int status, String body) {
    try {
      final message = jsonDecode(body)['error']['message'] as String;
      return status == 429
          ? 'Free tier limit reached, please try again in a minute.'
          : message;
    } catch (_) {
      return 'Request failed ($status).';
    }
  }
}
