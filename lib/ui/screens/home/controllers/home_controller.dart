import 'dart:async';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/demo_chat_service.dart';
import '../../../../core/services/voice_service.dart';
import '../../presets/controllers/presets_controller.dart';
import '../../widgets/bottom_sheets/services_sheet.dart';
import 'sidebar_controller.dart';
import '../../widgets/app_snackbar.dart';

/// A quick action chip under the orb.
class HomeAction {
  const HomeAction({required this.labelKey, required this.icon});

  /// Translation key of the label.
  final String labelKey;

  /// SVG asset path of the coloured icon.
  final String icon;
}

/// A photo or document sent along with a message.
class ChatAttachment {
  const ChatAttachment({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List bytes;
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');
}

/// A message in the current conversation.
class ChatMessage {
  ChatMessage.user(String text, {this.attachment})
    : isUser = true,
      text = text.obs,
      isStreaming = false.obs;

  ChatMessage.ai()
    : isUser = false,
      attachment = null,
      text = ''.obs,
      isStreaming = true.obs;

  final bool isUser;

  /// Photo or document the user sent with the message.
  final ChatAttachment? attachment;

  /// Pictures drawn for a "Generate image" reply.
  final images = <GeneratedImage>[].obs;

  /// Grows while the reply streams in.
  final RxString text;
  final RxBool isStreaming;
  final error = RxnString();

  /// null: no vote, true: liked, false: disliked.
  final liked = RxnBool();

  /// Web pages the reply was grounded on (Research only).
  final sources = <ChatSource>[].obs;
}

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final messages = <ChatMessage>[].obs;
  final hasText = false.obs;
  final isGenerating = false.obs;
  final showDisclaimer = true.obs;

  /// Whether this conversation is kept out of the chat history.
  final isTemporary = false.obs;

  /// Chip picked from the welcome screen, shown as a tag in the input.
  final selectedAction = Rxn<HomeAction>();

  /// Photo or document to send with the next message.
  final attachment = Rxn<ChatAttachment>();

  /// Whether the send button shows: there is text or an attachment.
  bool get canSend => hasText.value || attachment.value != null;

  /// The preset this chat is using, if it was started from one.
  final preset = Rxn<Preset>();

  /// The strip under the top bar saying what a preset cannot see; closed
  /// per preset chat.
  final showPresetNotice = true.obs;

  /// Stops the reply in progress, streamed or a generated image.
  StreamSubscription<Object?>? _reply;

  final _speech = SpeechToText();
  final _tts = FlutterTts();

  /// Whether the mic is on and the input shows the live waveform.
  final isListening = false.obs;

  /// Recent mic levels, 0..1, oldest first, for the waveform.
  final soundLevels = <double>[].obs;
  double _minLevel = 0, _maxLevel = 0;

  /// Off once dictation is sent or cancelled, so late words are dropped.
  bool _acceptSpeech = false;

  /// Completes when the recognizer delivers its final words.
  Completer<void>? _finalWords;

  /// The reply being read aloud, if any.
  final speakingMessage = Rxn<ChatMessage>();

  /// Bumped on every speak or stop, so an older read-aloud loop quits.
  int _speakRun = 0;

  static const researchAction = HomeAction(
    labelKey: 'home_research',
    icon: AppAssets.researchIcon,
  );

  /// Sidebar drawer position: 0 closed, 1 open.
  late final drawer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  final isDrawerOpen = false.obs;

  static const codeAction = HomeAction(
    labelKey: 'home_code',
    icon: AppAssets.codeIcon,
  );
  static const generateImagesAction = HomeAction(
    labelKey: 'home_generate_images',
    icon: AppAssets.generateImagesIcon,
  );
  static const integrationAction = HomeAction(
    labelKey: 'home_integration',
    icon: AppAssets.integrationIcon,
  );

  static const actions = [
    codeAction,
    researchAction,
    HomeAction(labelKey: 'home_canvas', icon: AppAssets.canvasIcon),
    generateImagesAction,
    integrationAction,
  ];

  @override
  void onInit() {
    super.onInit();
    drawer.addListener(() => isDrawerOpen.value = drawer.value > 0);
    messageController.addListener(
      () => hasText.value = messageController.text.trim().isNotEmpty,
    );
    // Picking a chat in the sidebar (or on search) shows it here.
    ever(Get.find<SidebarController>().selectedChatId, (_) => closeDrawer());
    _tts.setErrorHandler((_) => _stopSpeaking());
    ServicesSheet.precache();
  }

  void onMenu() => drawer.isDismissed ? drawer.forward() : closeDrawer();

  void closeDrawer() => drawer.reverse();

  /// Whether the web search tag is on for the next message.
  bool get _searchWeb => selectedAction.value == researchAction;

  /// Status line under the last message while waiting for the first words.
  String? get pendingStatus {
    final last = messages.lastOrNull;
    if (last == null || !last.isStreaming.value || last.text.isNotEmpty) {
      return null;
    }
    if (last.images.isNotEmpty) return null;
    if (isGeneratingImage.value) return 'chat_generating_image'.tr;
    return _searchWeb ? 'chat_searching_web'.tr : 'chat_thinking'.tr;
  }

  /// Whether the reply coming in is a picture, so the chat shows the
  /// image placeholder instead of the plain status line.
  final isGeneratingImage = false.obs;

  void onSend() {
    if (isListening.value) {
      onSendVoice();
      return;
    }
    final text = messageController.text.trim();
    final file = attachment.value;
    if (text.isEmpty && file == null) return;
    // Sending a new message replaces the reply still streaming in.
    if (isGenerating.value) onStop();
    _acceptSpeech = false;
    messageController.clear();
    attachment.value = null;
    messages.add(ChatMessage.user(text, attachment: file));
    _generate();
  }

  /// Stops the reply that is streaming in.
  void onStop() {
    _reply?.cancel();
    if (messages.lastOrNull case final last? when !last.isUser) _finish(last);
  }

  /// Asks again for [message], replacing it with a new reply.
  void onRegenerate(ChatMessage message) {
    if (isGenerating.value) return;
    final index = messages.indexOf(message);
    if (index < 0) return;
    messages.removeRange(index, messages.length);
    _generate();
  }

  void onCopy(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text.value));
    AppSnackbar.show('chat_copied'.tr);
  }

  void onLike(ChatMessage message, bool liked) =>
      message.liked.value = message.liked.value == liked ? null : liked;

  /// Reads [message] aloud, or stops if it is already being read.
  Future<void> onSpeak(ChatMessage message) async {
    final wasSpeaking = speakingMessage.value == message;
    await _stopSpeaking();
    if (wasSpeaking) return;
    if (isListening.value) onCancelVoice();

    final run = _speakRun;
    speakingMessage.value = message;
    try {
      await _prepareTts();
      for (final part in _speechParts(_plainText(message.text.value))) {
        if (run != _speakRun) return;
        if (await _tts.speak(part) != 1) throw Exception('speak failed');
      }
    } catch (_) {
      if (run == _speakRun) AppSnackbar.error('chat_speak_failed'.tr);
    }
    if (run == _speakRun) speakingMessage.value = null;
  }

  Future<void> _stopSpeaking() async {
    _speakRun++;
    speakingMessage.value = null;
    await _tts.stop();
  }

  /// Each speak call returns once it is read out. On iOS it plays through
  /// the speaker even in silent mode and after the mic set up recording.
  Future<void> _prepareTts() async {
    // Live talk shares the engine, so take the handler back.
    _tts.setErrorHandler((_) => _stopSpeaking());
    await _tts.awaitSpeakCompletion(true);
    if (GetPlatform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ], IosTextToSpeechAudioMode.spokenAudio);
    }
    await VoiceService.instance.apply(_tts);
  }

  /// Splits [text] at sentence ends into parts short enough for Android,
  /// which refuses to read long text in one go.
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

  void onShare(ChatMessage message) {
    final text = message.text.value;
    SharePlus.instance.share(
      ShareParams(
        text: text.isEmpty ? null : text,
        files: message.images.isEmpty
            ? null
            : [
                for (final (i, image) in message.images.indexed)
                  XFile.fromData(
                    image.bytes,
                    mimeType: image.mimeType,
                    name: 'aurenix_${i + 1}.${image.mimeType.split('/').last}',
                  ),
              ],
      ),
    );
  }

  Future<void> onOpenSource(ChatSource source) async {
    final opened = await launchUrl(
      Uri.parse(source.uri),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) AppSnackbar.error('chat_open_failed'.tr);
  }

  /// Markdown without the symbols, so they are not read out.
  static String _plainText(String markdown) => markdown
      .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!)
      .replaceAll(RegExp(r'[*_#`>|~]'), '')
      .replaceAll(RegExp(r'^\s*[-+]\s+', multiLine: true), '');

  /// Starts dictation into the input, or stops it if already listening.
  Future<void> onMic() async {
    if (isListening.value) return _stopListening(cancel: false);
    bool available;
    try {
      available = await _speech.initialize();
      // The plugin is shared with live talk and only takes the listeners
      // on its first initialize, so set them every time.
      _speech
        ..statusListener = _onSpeechStatus
        ..errorListener = _onSpeechError;
    } catch (_) {
      // e.g. the plugin is missing after a hot reload, or no recognizer.
      available = false;
    }
    if (!available) {
      AppSnackbar.error('chat_mic_unavailable'.tr);
      return;
    }
    await _stopSpeaking();
    soundLevels.clear();
    _minLevel = _maxLevel = 0;
    isListening.value = true;
    _acceptSpeech = true;
    _finalWords = Completer();
    await _speech.listen(
      onResult: _onSpeechResult,
      onSoundLevelChange: _onSoundLevel,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  void _onSpeechStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      isListening.value = false;
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!isListening.value) return;
    isListening.value = false;
    AppSnackbar.error(switch (error.errorMsg) {
      'error_no_match' || 'error_speech_timeout' => 'chat_voice_empty'.tr,
      'error_permission' => 'chat_mic_unavailable'.tr,
      final msg => msg,
    });
  }

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
    _acceptSpeech = false;
    if (messageController.text.trim().isEmpty) {
      AppSnackbar.error('chat_voice_empty'.tr);
      return;
    }
    onSend();
  }

  /// Stops dictation and throws away what was said.
  void onCancelVoice() {
    _acceptSpeech = false;
    _stopListening(cancel: true);
    messageController.clear();
  }

  Future<void> _stopListening({required bool cancel}) async {
    isListening.value = false;
    cancel ? await _speech.cancel() : await _speech.stop();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!_acceptSpeech) return;
    if (result.finalResult && !(_finalWords?.isCompleted ?? true)) {
      _finalWords!.complete();
    }
    messageController.value = TextEditingValue(
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
    if (soundLevels.length > 120) soundLevels.removeAt(0);
  }

  /// Streams the AI reply to the conversation so far into a new message.
  void _generate() {
    final history = [
      for (final m in messages)
        if (m.error.value == null &&
            (m.text.isNotEmpty || m.attachment != null))
          ChatTurn(
            role: m.isUser ? ChatRole.user : ChatRole.model,
            text: m.text.value,
            file: m.attachment?.bytes,
            mimeType: m.attachment?.mimeType ?? 'image/jpeg',
          ),
    ];
    final reply = ChatMessage.ai();
    messages.add(reply);
    isGenerating.value = true;
    // A picture comes back when the chip is on, or when the message asks
    // for one, or when a photo was sent to be changed.
    isGeneratingImage.value =
        selectedAction.value == generateImagesAction ||
        (messages.length > 1 &&
            DemoChatService.wantsImage(
              messages[messages.length - 2].text.value,
              hasImage:
                  messages[messages.length - 2].attachment?.isImage ?? false,
            ));
    _scrollToBottom();

    if (isGeneratingImage.value) {
      // Only the latest message: older photos would be redrawn otherwise.
      _reply = DemoChatService.instance
          .generateImage(history.isEmpty ? const [] : [history.last])
          .asStream()
          .listen(
            (result) {
              reply.text.value = result.text;
              reply.images.addAll(result.images);
              _scrollToBottom();
            },
            onError: (Object e) {
              reply.error.value = e is ApiException
                  ? e.message
                  : 'chat_error'.tr;
              _finish(reply);
            },
            onDone: () => _finish(reply),
            cancelOnError: true,
          );
      return;
    }

    _reply = DemoChatService.instance
        .streamChat(
          history,
          searchWeb: _searchWeb,
          instruction: selectedAction.value == codeAction
              ? _codeInstruction
              : null,
        )
        .listen(
          (chunk) {
            reply.text.value += chunk.text;
            reply.sources.addAll(
              chunk.sources.where(
                (s) => reply.sources.every((old) => old.uri != s.uri),
              ),
            );
            _scrollToBottom();
          },
          onError: (Object e) {
            reply.error.value = e is ApiException ? e.message : 'chat_error'.tr;
            _finish(reply);
          },
          onDone: () => _finish(reply),
          cancelOnError: true,
        );
  }

  static const _codeInstruction =
      'The user wants code. Reply with complete, working code in fenced '
      'Markdown code blocks tagged with the language, then briefly explain '
      'how it works and how to run it.';

  void _finish(ChatMessage reply) {
    _reply = null;
    reply.isStreaming.value = false;
    isGenerating.value = false;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final end = scrollController.position.maxScrollExtent;
      final gap = end - scrollController.position.pixels;
      if (gap <= 0) return;
      // Words arrive a few times a second: starting a new animation each
      // time fights the one before it, so small steps just jump.
      if (gap < 120) {
        scrollController.jumpTo(end);
        return;
      }
      scrollController.animateTo(
        end,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  /// Clears the conversation. A [temporary] chat isn't saved to history.
  /// Starts a chat with [preset], with [starter] typed into the input.
  ///
  /// Presets is reached from the sidebar, which stays open behind it, so
  /// the drawer is snapped shut here: home is still covered, and the chat
  /// must be what shows when it comes back.
  void startPreset(Preset preset, [String? starter]) {
    onNewChat();
    this.preset.value = preset;
    showPresetNotice.value = true;
    if (starter != null) onQuickStarter(starter);
    drawer.value = 0;
    Get.find<SidebarController>().selectedChatId.value = null;
  }

  /// Puts a quick starter prompt into the input, ready to send.
  void onQuickStarter(String starter) {
    messageController.text = starter;
    messageController.selection = TextSelection.collapsed(
      offset: starter.length,
    );
  }

  void onClosePresetNotice() => showPresetNotice.value = false;

  Future<void> onVisitPresetSite() async {
    final preset = this.preset.value;
    if (preset != null) await openPresetSite(preset);
  }

  void onNewChat({bool temporary = false}) {
    isTemporary.value = temporary;
    preset.value = null;
    _reply?.cancel();
    _stopSpeaking();
    if (isListening.value) onCancelVoice();
    _reply = null;
    isGenerating.value = false;
    messages.clear();
    attachment.value = null;
    selectedAction.value = null;
    messageController.clear();
  }

  void onAction(HomeAction action) => selectedAction.value = action;

  void onClearAction() => selectedAction.value = null;

  void onCloseDisclaimer() => showDisclaimer.value = false;

  /// The round waveform button opens live talk.
  Future<void> onVoice() async {
    if (isListening.value) onCancelVoice();
    await _stopSpeaking();
    Get.toNamed(AppRoutes.liveTalk);
  }

  /// Opens the services sheet from the + in the input.
  void onAttach() => showModalBottomSheet<void>(
    context: Get.context!,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 450),
      reverseDuration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (_) => const ServicesSheet(),
  );

  /// A tile in the services sheet picks its action, like the welcome chips.
  void onService(HomeAction action) {
    Get.back();
    onAction(action);
  }

  /// Closes the services sheet and opens the integrations screen.
  void onIntegrations() {
    Get.back();
    Get.toNamed(AppRoutes.connectedApps);
  }

  /// Types Gemini reads inline, by file extension.
  static const _documentTypes = {
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'md': 'text/markdown',
    'csv': 'text/csv',
    'html': 'text/html',
    'json': 'application/json',
    'xml': 'text/xml',
    'rtf': 'text/rtf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };

  /// Requests with more than this inline are refused by the API.
  static const _maxAttachmentBytes = 15 * 1024 * 1024;

  /// Picks a document to send with the next message.
  Future<void> onAttachDocument() async {
    Get.back();
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: _documentTypes.keys.toList(),
      );
      if (file == null) return;
      final mimeType = _documentTypes[file.extension?.toLowerCase()];
      if (mimeType == null) {
        AppSnackbar.error('chat_file_unsupported'.tr);
        return;
      }
      _setAttachment(file.name, await file.readAsBytes(), mimeType);
    } catch (_) {
      AppSnackbar.error('chat_file_failed'.tr);
    }
  }

  /// Takes a photo to send with the next message.
  Future<void> onCaptureImage() async {
    Get.back();
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (photo == null) return;
      _setAttachment(photo.name, await photo.readAsBytes(), 'image/jpeg');
    } catch (_) {
      AppSnackbar.error('chat_camera_unavailable'.tr);
    }
  }

  void _setAttachment(String name, Uint8List bytes, String mimeType) {
    if (bytes.length > _maxAttachmentBytes) {
      AppSnackbar.error('chat_file_too_large'.tr);
      return;
    }
    attachment.value = ChatAttachment(
      name: name,
      bytes: bytes,
      mimeType: mimeType,
    );
  }

  void onRemoveAttachment() => attachment.value = null;

  // TODO: wire these up once the menus exist.
  void onModelTap() {}
  void onMore() {}

  @override
  void onClose() {
    _reply?.cancel();
    _speech.cancel();
    _tts.stop();
    messageController.dispose();
    scrollController.dispose();
    drawer.dispose();
    super.onClose();
  }
}
