import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Speaking into the chat input: the mic, the live waveform and the words
/// the recognizer hands back.
///
/// Owned by [HomeController] rather than registered on its own, so it lives
/// and dies with the chat screen. It writes straight into the input's
/// [TextEditingController]; everything else it needs is a callback.
class DictationController {
  DictationController({
    required this.input,
    required this.onBeforeListen,
    required this.onSend,
  });

  /// The chat input the recognized words are typed into.
  final TextEditingController input;

  /// Run before the mic opens, so whatever is being read aloud stops first.
  final Future<void> Function() onBeforeListen;

  /// Sends what was dictated.
  final VoidCallback onSend;

  final _speech = SpeechToText();

  /// Whether the mic is on and the input shows the live waveform.
  final isListening = false.obs;

  /// Recent mic levels, 0..1, oldest first, for the waveform.
  final soundLevels = <double>[].obs;
  double _minLevel = 0, _maxLevel = 0;

  /// How many levels the waveform keeps.
  static const _levelHistory = 120;

  /// Off once dictation is sent or cancelled, so late words are dropped.
  bool _accept = false;

  /// Completes when the recognizer delivers its final words.
  Completer<void>? _finalWords;

  /// Starts dictation into the input, or stops it if already listening.
  Future<void> onMic() async {
    if (isListening.value) return _stopListening(cancel: false);
    bool available;
    try {
      available = await _speech.initialize();
      // The plugin is shared with live talk and only takes the listeners
      // on its first initialize, so set them every time.
      _speech
        ..statusListener = _onStatus
        ..errorListener = _onError;
    } catch (_) {
      // e.g. the plugin is missing after a hot reload, or no recognizer.
      available = false;
    }
    if (!available) {
      AppSnackbar.error(AppStrings.chatMicUnavailable.tr);
      return;
    }
    await onBeforeListen();
    soundLevels.clear();
    _minLevel = _maxLevel = 0;
    isListening.value = true;
    _accept = true;
    _finalWords = Completer();
    await _speech.listen(
      onResult: _onResult,
      onSoundLevelChange: _onSoundLevel,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  /// Drops any words the recognizer is still about to deliver, for when
  /// the message is sent some other way.
  void stopAccepting() => _accept = false;

  /// Stops dictation and sends what was said.
  Future<void> onSendVoice() async {
    final finalWords = _finalWords;
    await _stopListening(cancel: false);
    // The recognizer often delivers the last words just after stopping.
    if (finalWords != null && !finalWords.isCompleted) {
      await finalWords.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
    }
    _accept = false;
    if (input.text.trim().isEmpty) {
      AppSnackbar.error(AppStrings.chatVoiceEmpty.tr);
      return;
    }
    onSend();
  }

  /// Stops dictation and throws away what was said.
  void onCancelVoice() {
    _accept = false;
    _stopListening(cancel: true);
    input.clear();
  }

  Future<void> _stopListening({required bool cancel}) async {
    isListening.value = false;
    cancel ? await _speech.cancel() : await _speech.stop();
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      isListening.value = false;
    }
  }

  void _onError(SpeechRecognitionError error) {
    if (!isListening.value) return;
    isListening.value = false;
    AppSnackbar.error(switch (error.errorMsg) {
      'error_no_match' ||
      'error_speech_timeout' => AppStrings.chatVoiceEmpty.tr,
      'error_permission' => AppStrings.chatMicUnavailable.tr,
      final msg => msg,
    });
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!_accept) return;
    if (result.finalResult && !(_finalWords?.isCompleted ?? true)) {
      _finalWords!.complete();
    }
    input.value = TextEditingValue(
      text: result.recognizedWords,
      selection: TextSelection.collapsed(offset: result.recognizedWords.length),
    );
  }

  /// Levels come in dB on a platform dependent scale, so they are scaled
  /// between the quietest and loudest seen so far.
  void _onSoundLevel(double level) {
    if (soundLevels.isEmpty) _minLevel = _maxLevel = level;
    _minLevel = level < _minLevel ? level : _minLevel;
    _maxLevel = level > _maxLevel ? level : _maxLevel;
    final range = _maxLevel - _minLevel;
    soundLevels.add(range == 0 ? 0 : (level - _minLevel) / range);
    if (soundLevels.length > _levelHistory) soundLevels.removeAt(0);
  }

  void dispose() {
    _speech.cancel();
    isListening.close();
    soundLevels.close();
  }
}
