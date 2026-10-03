import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/demo_chat_service.dart';
import 'package:aurenix/core/services/screen_share_service.dart';
import 'package:aurenix/core/services/voice_service.dart';
import 'package:aurenix/ui/screens/widgets/bottom_sheets/audio_output_sheet.dart';
import 'package:aurenix/ui/screens/widgets/app_snackbar.dart';

enum LiveStatus { idle, listening, thinking, speaking }

/// Somewhere the voice can play: the phone speaker or connected headphones.
class AudioOutput {
  const AudioOutput({
    required this.id,
    required this.name,
    this.isSpeaker = false,
  });

  static const speaker = AudioOutput(id: 'speaker', name: '', isSpeaker: true);

  final String id;
  final String name;
  final bool isSpeaker;
}

/// Hands-free voice chat: listens, sends what was said to the AI, reads the
/// reply aloud, then listens again. With the camera on, each question goes
/// with a photo of what the camera sees; with the screen shared, with a
/// screenshot instead.
class LiveTalkController extends GetxController with WidgetsBindingObserver {
  final status = LiveStatus.idle.obs;

  /// What the user is saying, then the AI reply while it is read out.
  final caption = ''.obs;

  final showCaptions = true.obs;
  final isMuted = false.obs;

  /// Filled each time the output sheet opens, speaker first.
  final outputs = <AudioOutput>[AudioOutput.speaker].obs;
  final selectedOutput = AudioOutput.speaker.id.obs;

  /// Set while the camera is on and its preview can be shown.
  final camera = Rxn<CameraController>();

  /// The screen is being captured; see [ScreenShareService].
  final isSharingScreen = false.obs;

  final _speech = SpeechToText();
  final _tts = FlutterTts();
  final _history = <ChatTurn>[];

  StreamSubscription<ChatChunk>? _reply;

  /// Bumped to drop callbacks from a turn that was interrupted.
  var _turn = 0;
  var _closed = false;

  var _cameraStarting = false;
  var _shareStarting = false;

  /// The camera was on when the app went to the background.
  var _reopenCamera = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // The system can end the share on its own, e.g. from the status bar.
    ScreenShareService.instance.onStopped = () => isSharingScreen.value = false;
  }

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
          AppSnackbar.error('chat_mic_unavailable'.tr);
        };
    } catch (_) {
      available = false;
    }
    if (!available) {
      AppSnackbar.error('chat_mic_unavailable'.tr);
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

  Future<void> _ask(String text) async {
    final turn = ++_turn;
    status.value = LiveStatus.thinking;
    _speech.stop();
    final image = await _snapshot();
    if (turn != _turn) return;
    // Only the latest photo is sent; earlier ones would make every request
    // bigger, and the replies already describe what they showed.
    final index = _history.length;
    _history.add(ChatTurn(role: ChatRole.user, text: text, file: image));

    final buffer = StringBuffer();
    _reply = DemoChatService.instance
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
            _history[index] = ChatTurn(role: ChatRole.user, text: text);
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
    try {
      await _prepareTts();
      for (final part in _speechParts(text)) {
        if (turn != _turn) return;
        if (await _tts.speak(part) != 1) break;
      }
    } catch (_) {
      // Keep the conversation going with the caption only.
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
    await VoiceService.instance.apply(_tts);
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

  Future<void> onAudioOutput() async {
    await _loadOutputs();
    await showModalBottomSheet<void>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      elevation: 0,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 450),
        reverseDuration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (_) => const AudioOutputSheet(),
    );
  }

  // TODO: route the voice to the picked output. The system currently plays
  // it on whatever it considers active (usually the last connected device).
  void onSelectOutput(AudioOutput output) {
    selectedOutput.value = output.id;
    Get.back();
  }

  Future<void> _loadOutputs() async {
    final found = <AudioOutput>[AudioOutput.speaker];
    try {
      final session = await AudioSession.instance;
      final devices = await session.getDevices(includeInputs: false);
      final names = <String>{};
      for (final device in devices) {
        // A Bluetooth headset shows up once per profile, so key by name.
        if (_isHeadphones(device) && names.add(device.name)) {
          found.add(AudioOutput(id: device.name, name: device.name));
        }
      }
    } catch (_) {
      // The speaker alone is still a valid choice.
    }
    outputs.assignAll(found);
    if (!found.any((o) => o.id == selectedOutput.value)) {
      selectedOutput.value = AudioOutput.speaker.id;
    }
  }

  // By name, since the audio_session device type enum is experimental.
  static const _headphoneTypes = {
    'wiredHeadset',
    'wiredHeadphones',
    'bluetoothA2dp',
    'bluetoothSco',
    'bluetoothLe',
    'usbAudio',
    'hearingAid',
    'airPlay',
    'carAudio',
  };

  static bool _isHeadphones(AudioDevice device) =>
      _headphoneTypes.contains(device.type.name);

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

  /// A JPEG of the shared screen or of what the camera sees, or null when
  /// neither is on.
  Future<Uint8List?> _snapshot() async {
    if (isSharingScreen.value) return ScreenShareService.instance.capture();
    final controller = camera.value;
    if (controller == null || controller.value.isTakingPicture) return null;
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      File(file.path).delete().ignore();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> onCamera() =>
      camera.value == null ? _openCamera() : _closeCamera();

  Future<void> _openCamera() async {
    if (_cameraStarting || _closed) return;
    _cameraStarting = true;
    CameraController? controller;
    try {
      // One view at a time: the camera replaces the screen.
      await _stopScreenShare();
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', null);
      controller = CameraController(
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
        // The microphone belongs to speech recognition.
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (_closed) return await controller.dispose();
      camera.value = controller;
    } catch (e) {
      debugPrint('Live talk camera failed: $e');
      controller?.dispose();
      final denied = e is CameraException && e.code.startsWith('CameraAccess');
      AppSnackbar.error(
        (denied ? 'live_camera_denied' : 'live_camera_unavailable').tr,
      );
    } finally {
      _cameraStarting = false;
    }
  }

  Future<void> _closeCamera() async {
    final controller = camera.value;
    // Drop the preview before disposing what it shows.
    camera.value = null;
    await controller?.dispose();
  }

  /// The camera is released while the app is in the background, as the
  /// platforms require, and comes back on return.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && camera.value != null) {
      _reopenCamera = true;
      _closeCamera();
    } else if (state == AppLifecycleState.resumed && _reopenCamera) {
      _reopenCamera = false;
      _openCamera();
    }
  }

  Future<void> onScreenShare() =>
      isSharingScreen.value ? _stopScreenShare() : _startScreenShare();

  /// Asks for consent, then sends a screenshot with each question until
  /// the user stops. On Android the share follows the user into other apps.
  Future<void> _startScreenShare() async {
    if (_shareStarting || _closed) return;
    _shareStarting = true;
    try {
      // One view at a time: the screen replaces the camera. Clear the
      // flag too, since the consent dialog pauses the app.
      await _closeCamera();
      _reopenCamera = false;
      final started = await ScreenShareService.instance.start(
        channelName: 'live_share_channel'.tr,
        title: 'live_share_notification_title'.tr,
        text: 'live_share_notification_text'.tr,
      );
      if (_closed) return await ScreenShareService.instance.stop();
      if (started == null) {
        AppSnackbar.error('live_share_unavailable'.tr);
      }
      // False means the user declined, which needs no message.
      if (started != true) return;
      isSharingScreen.value = true;
    } finally {
      _shareStarting = false;
    }
  }

  Future<void> _stopScreenShare() async {
    if (!isSharingScreen.value) return;
    isSharingScreen.value = false;
    await ScreenShareService.instance.stop();
  }

  /// Opens Voice Preferences. The conversation pauses so the mic doesn't
  /// pick up the voice previews, and picks up again on return.
  Future<void> onSettings() async {
    await _interrupt();
    caption.value = '';
    await Get.toNamed(AppRoutes.voiceSettings);
    if (!_closed) _listen();
  }

  void onEnd() => Get.back();

  @override
  void onClose() {
    _closed = true;
    WidgetsBinding.instance.removeObserver(this);
    ScreenShareService.instance.onStopped = null;
    _interrupt();
    _closeCamera();
    _stopScreenShare();
    super.onClose();
  }
}
