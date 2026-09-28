import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/services/api_service.dart';

enum LiveStatus { idle, listening, thinking, speaking }

/// Hands-free voice chat: listens, sends what was said to the AI, reads the
/// reply aloud, then listens again.
class LiveTalkController extends GetxController {
  final status = LiveStatus.idle.obs;

  /// What the user is saying, then the AI reply while it is read out.
  final caption = ''.obs;

  final showCaptions = true.obs;
  final isSpeakerOn = true.obs;
  final isMuted = false.obs;

  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _history = <ChatTurn>[];

  StreamSubscription<ChatChunk>? _reply;

  /// Bumped to drop callbacks from a turn that was interrupted.
  var _turn = 0;
  var _closed = false;

  @override
  void onReady() {
    super.onReady();
    _listen();
  }

  Future<void> _listen() async {
    if (_closed || isMuted.value) return;
    bool available;
    try {
      available = await _speech.initialize();
      // The plugin is shared with the home screen and only takes the
      // listeners on its first initialize, so set them every time.
      _speech
        ..statusListener = _onStatus
        ..errorListener = (error) {
          if (error.errorMsg != 'error_permission') {
            return _onStatus(SpeechToText.doneStatus);
          }
          isMuted.value = true;
          status.value = LiveStatus.idle;
          Get.rawSnackbar(message: 'chat_mic_unavailable'.tr);
        };
    } catch (_) {
      available = false;
    }
    if (!available) {
      Get.rawSnackbar(message: 'chat_mic_unavailable'.tr);
      return;
    }
    if (_closed || isMuted.value) return;
    _turn++;
    caption.value = '';
    status.value = LiveStatus.listening;
    await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 2),
      ),
    );
  }

  /// Listening can end without a final result (silence, an error), so
  /// start again unless something else took over.
  void _onStatus(String value) {
    if (value != SpeechToText.doneStatus || _closed) return;
    if (status.value == LiveStatus.listening) {
      status.value = LiveStatus.idle;
      _listen();
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (status.value != LiveStatus.listening) return;
    caption.value = result.recognizedWords;
    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      _ask(result.recognizedWords.trim());
    }
  }

  void _ask(String text) {
    final turn = ++_turn;
    status.value = LiveStatus.thinking;
    _speech.stop();
    _history.add(ChatTurn(role: ChatRole.user, text: text));

    final buffer = StringBuffer();
    _reply = ApiService.instance
        .streamChat(_history)
        .listen(
          (chunk) => buffer.write(chunk.text),
          onError: (Object e) {
            if (turn != _turn) return;
            _history.removeLast();
            _speak(turn, e is ApiException ? e.message : 'chat_error'.tr);
          },
          onDone: () {
            if (turn != _turn) return;
            final reply = _plainText(buffer.toString());
            _history.add(ChatTurn(role: ChatRole.model, text: reply));
            _speak(turn, reply);
          },
          cancelOnError: true,
        );
  }

  Future<void> _speak(int turn, String text) async {
    _reply = null;
    status.value = LiveStatus.speaking;
    caption.value = text;
    if (isSpeakerOn.value) {
      try {
        await _prepareTts();
        for (final part in _speechParts(text)) {
          if (turn != _turn) return;
          if (await _tts.speak(part) != 1) break;
        }
      } catch (_) {
        // Keep the conversation going with the caption only.
      }
    }
    if (turn != _turn) return;
    status.value = LiveStatus.idle;
    _listen();
  }

  Future<void> _prepareTts() async {
    await _tts.awaitSpeakCompletion(true);
    if (GetPlatform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ], IosTextToSpeechAudioMode.spokenAudio);
    }
  }

  /// Sentence sized parts, since Android refuses to read long text at once.
  static List<String> _speechParts(String text, {int maxLength = 1000}) {
    final parts = <String>[];
    var current = '';
    for (final sentence in text.split(RegExp(r'(?<=[.!?\n])\s+'))) {
      if (current.isNotEmpty &&
          current.length + sentence.length + 1 > maxLength) {
        parts.add(current);
        current = '';
      }
      current = current.isEmpty ? sentence : '$current $sentence';
      while (current.length > maxLength) {
        parts.add(current.substring(0, maxLength));
        current = current.substring(maxLength);
      }
    }
    if (current.trim().isNotEmpty) parts.add(current);
    return parts;
  }

  /// Markdown without the symbols, so they are neither shown nor read out.
  static String _plainText(String markdown) => markdown
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
      .replaceAll(RegExp(r'[*_#`>|~]'), '')
      .replaceAll(RegExp(r'^\s*[-+]\s+', multiLine: true), '')
      .trim();

  /// Stops whatever is happening in the current turn.
  Future<void> _interrupt() async {
    _turn++;
    _reply?.cancel();
    _reply = null;
    status.value = LiveStatus.idle;
    await _speech.cancel();
    await _tts.stop();
  }

  void onToggleCaptions() => showCaptions.toggle();

  void onToggleSpeaker() {
    isSpeakerOn.toggle();
    if (!isSpeakerOn.value && status.value == LiveStatus.speaking) {
      _tts.stop();
    }
  }

  /// Muting stops listening (and cuts off a reply); unmuting listens again.
  Future<void> onToggleMic() async {
    isMuted.toggle();
    if (isMuted.value) {
      await _interrupt();
      caption.value = '';
    } else {
      _listen();
    }
  }

  // TODO: wire these up once video, screen sharing and voice settings exist.
  void onCamera() => Get.rawSnackbar(message: 'live_coming_soon'.tr);
  void onScreenShare() => Get.rawSnackbar(message: 'live_coming_soon'.tr);
  void onSettings() => Get.rawSnackbar(message: 'live_coming_soon'.tr);

  void onEnd() => Get.back();

  @override
  void onClose() {
    _closed = true;
    _interrupt();
    super.onClose();
  }
}
