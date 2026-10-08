import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aurenix/core/constants/app_assets.dart';
import 'package:aurenix/core/routes/app_routes.dart';
import 'package:aurenix/core/services/chat_quota_service.dart';
import 'package:aurenix/core/services/demo_chat_service.dart';
import 'package:aurenix/core/services/voice_service.dart';
import 'package:aurenix/features/home/controllers/chat_attachment_controller.dart';
import 'package:aurenix/features/home/controllers/dictation_controller.dart';
import 'package:aurenix/features/home/controllers/sidebar_drawer_controller.dart';
import 'package:aurenix/features/presets/controllers/presets_controller.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/services_sheet.dart';
import 'package:aurenix/commons/widgets/bottom_sheets/chat_limit_sheet.dart';
import 'package:aurenix/features/home/controllers/sidebar_controller.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/features/home/models/chat_message.dart';
import 'package:aurenix/features/home/models/home_action.dart';
import 'package:aurenix/features/presets/models/preset.dart';
import 'package:aurenix/core/constants/app_strings.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final messageController = TextEditingController();
  final messageFocus = FocusNode();
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
  final attachment = ChatAttachmentController();

  /// Whether the send button shows: there is text or an attachment.
  bool get canSend => hasText.value || attachment.value.value != null;

  /// The preset this chat is using, if it was started from one.
  final preset = Rxn<Preset>();

  /// The strip under the top bar saying what a preset cannot see; closed
  /// per preset chat.
  final showPresetNotice = true.obs;

  /// Stops the reply in progress, streamed or a generated image.
  StreamSubscription<Object?>? _reply;

  final _voice = VoiceService.instance;

  /// The mic, the waveform and the words it hands back.
  late final dictation = DictationController(
    input: messageController,
    onBeforeListen: _stopSpeaking,
    onSend: onSend,
  );

  /// The reply being read aloud, if any.
  final speakingMessage = Rxn<ChatMessage>();

  /// Bumped on every speak or stop, so an older read-aloud loop quits.
  int _speakRun = 0;

  /// Open/closed position of the sidebar drawer.
  late final drawer = SidebarDrawerController(vsync: this);

  // --- The welcome chips, also offered in the services sheet. ---

  static const researchAction = HomeAction(
    labelKey: AppStrings.homeResearch,
    icon: AppAssets.researchIcon,
  );
  static const codeAction = HomeAction(
    labelKey: AppStrings.homeCode,
    icon: AppAssets.codeIcon,
  );
  static const generateImagesAction = HomeAction(
    labelKey: AppStrings.homeGenerateImages,
    icon: AppAssets.generateImagesIcon,
  );
  static const integrationAction = HomeAction(
    labelKey: AppStrings.homeIntegration,
    icon: AppAssets.integrationIcon,
  );

  static const actions = [
    codeAction,
    researchAction,
    HomeAction(labelKey: AppStrings.homeCanvas, icon: AppAssets.canvasIcon),
    generateImagesAction,
    integrationAction,
  ];

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(
      () => hasText.value = messageController.text.trim().isNotEmpty,
    );
    // Picking a chat in the sidebar (or on search) shows it here.
    ever(Get.find<SidebarController>().selectedChatId, (_) => drawer.close());
    ServicesSheet.precache();
    WidgetsBinding.instance.addObserver(this);
  }

  /// The reset timer does not run while the app is paused, so the clock is
  /// checked again on the way back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _quota.refresh();
  }

  ChatQuotaService get _quota => ChatQuotaService.instance;

  /// Whether the free allowance is used up: the chat is shut and the
  /// upgrade card closes it off until the window resets.
  bool get isChatLimited => _quota.isLimited;

  /// Turns a message away once the allowance is used up, bringing up the
  /// upgrade sheet instead. Returns whether the chat is shut.
  bool _blockedByLimit() {
    if (!isChatLimited) return false;
    _scrollToBottom();
    ChatLimitSheet.show();
    return true;
  }

  /// Whether the web search tag is on for the next message.
  bool get _searchWeb => selectedAction.value == researchAction;

  /// Status line under the last message while waiting for the first words.
  String? get pendingStatus {
    final last = messages.lastOrNull;
    if (last == null || !last.isStreaming.value || last.text.isNotEmpty) {
      return null;
    }
    if (last.images.isNotEmpty) return null;
    if (isGeneratingImage.value) return AppStrings.chatGeneratingImage.tr;
    return _searchWeb
        ? AppStrings.chatSearchingWeb.tr
        : AppStrings.chatThinking.tr;
  }

  /// Whether the reply coming in is a picture, so the chat shows the
  /// image placeholder instead of the plain status line.
  final isGeneratingImage = false.obs;

  void onSend() {
    if (dictation.isListening.value) {
      dictation.onSendVoice();
      return;
    }
    final text = messageController.text.trim();
    final file = attachment.value.value;
    if (text.isEmpty && file == null) return;
    if (_blockedByLimit()) return;
    // Sending a new message replaces the reply still streaming in.
    if (isGenerating.value) onStop();
    dictation.stopAccepting();
    // Back to plain bubbles: a selection left open from the menu.
    for (final message in messages) {
      message.selectable.value = false;
    }
    messageController.clear();
    attachment.clear();
    messages.add(ChatMessage.user(text, attachment: file));
    _rememberChat();
    _generate();
  }

  /// Keeps the conversation in the drawer's chat list. A temporary chat is
  /// deliberately throwaway, so it is left out.
  void _rememberChat() {
    if (isTemporary.value) return;
    final first = messages.firstWhereOrNull((m) => m.isUser);
    if (first == null) return;
    Get.find<SidebarController>().recordChat(messages, first.text.value);
  }

  /// Puts a conversation from the history back on screen.
  void openChat(List<ChatMessage> saved) {
    onNewChat();
    messages.addAll(saved);
    _scrollToBottom();
  }

  /// Stops the reply that is streaming in.
  void onStop() {
    _reply?.cancel();
    if (messages.lastOrNull case final last? when !last.isUser) _finish(last);
  }

  /// Asks again for [message], replacing it with a new reply.
  void onRegenerate(ChatMessage message) {
    if (isGenerating.value || _blockedByLimit()) return;
    final index = messages.indexOf(message);
    if (index < 0) return;
    messages.removeRange(index, messages.length);
    _generate();
  }

  void onCopy(ChatMessage message) {
    Clipboard.setData(ClipboardData(text: message.text.value));
    AppSnackbar.show(AppStrings.chatCopied.tr);
  }

  /// Turns the system selection handles on for one sent message, so its
  /// words can be picked apart; any other message goes back to plain.
  void onSelectText(ChatMessage message) {
    for (final other in messages) {
      other.selectable.value = other == message;
    }
  }

  /// Puts a sent message back in the input to be rewritten. The message
  /// and everything after it leave the chat, so sending asks again from
  /// that point.
  void onEditMessage(ChatMessage message) {
    final index = messages.indexOf(message);
    if (index < 0) return;
    if (isGenerating.value) onStop();
    messages.removeRange(index, messages.length);
    attachment.value.value = message.attachment;
    messageController.text = message.text.value;
    messageController.selection = TextSelection.collapsed(
      offset: messageController.text.length,
    );
    messageFocus.requestFocus();
  }

  void onLike(ChatMessage message, bool liked) =>
      message.liked.value = message.liked.value == liked ? null : liked;

  /// Reads [message] aloud, or stops if it is already being read.
  Future<void> onSpeak(ChatMessage message) async {
    final wasSpeaking = speakingMessage.value == message;
    await _stopSpeaking();
    if (wasSpeaking) return;
    if (dictation.isListening.value) dictation.onCancelVoice();

    final run = _speakRun;
    speakingMessage.value = message;
    try {
      await _voice.speak(VoiceService.plainText(message.text.value));
    } catch (_) {
      if (run == _speakRun) AppSnackbar.error(AppStrings.chatSpeakFailed.tr);
    }
    if (run == _speakRun) speakingMessage.value = null;
  }

  Future<void> _stopSpeaking() async {
    _speakRun++;
    speakingMessage.value = null;
    await _voice.stop();
  }

  void onShare(ChatMessage message) {
    final text = message.text.value;
    final sent = message.attachment;
    SharePlus.instance.share(
      ShareParams(
        text: text.isEmpty ? null : text,
        files: sent != null
            ? [
                XFile.fromData(
                  sent.bytes,
                  mimeType: sent.mimeType,
                  name: sent.name,
                ),
              ]
            : message.images.isEmpty
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
    if (!opened) AppSnackbar.error(AppStrings.chatOpenFailed.tr);
  }

  /// Streams the AI reply to the conversation so far into a new message.
  void _generate() {
    _quota.recordMessage();
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
    _rememberChat();
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
                  : AppStrings.chatError.tr;
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
            reply.error.value = e is ApiException
                ? e.message
                : AppStrings.chatError.tr;
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
    // The reply that used up the allowance has landed: say so now rather
    // than on the next send.
    if (isChatLimited && Get.currentRoute == AppRoutes.home) {
      ChatLimitSheet.show();
    }
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
    drawer.snapShut();
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
    // A reply still coming in belongs to the chat we are leaving; mark it
    // done so its stored copy does not stay stuck mid-stream.
    if (messages.lastOrNull case final last? when !last.isUser) {
      last.isStreaming.value = false;
    }
    _stopSpeaking();
    if (dictation.isListening.value) dictation.onCancelVoice();
    _reply = null;
    isGenerating.value = false;
    messages.clear();
    attachment.clear();
    selectedAction.value = null;
    messageController.clear();
  }

  void onAction(HomeAction action) => selectedAction.value = action;

  void onClearAction() => selectedAction.value = null;

  void onCloseDisclaimer() => showDisclaimer.value = false;

  /// The round waveform button opens live talk.
  Future<void> onVoice() async {
    if (dictation.isListening.value) dictation.onCancelVoice();
    await _stopSpeaking();
    unawaited(Get.toNamed(AppRoutes.liveTalk));
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

  // TODO: wire this up once the model picker exists.
  void onModelTap() {}

  /// The top bar's "..." — the Rename / Archive / Move / Delete card for
  /// the chat on screen. A conversation that has not been saved yet has
  /// nothing to act on.
  void onMore(Rect anchor) {
    final sidebar = Get.find<SidebarController>();
    final chat = sidebar.selectedChat;
    if (chat == null) {
      AppSnackbar.show(AppStrings.chatMenuUnsaved.tr);
      return;
    }
    sidebar.showChatMenu(context: Get.context!, anchor: anchor, chat: chat);
  }

  @override
  void onClose() {
    _reply?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    dictation.dispose();
    attachment.dispose();
    _voice.stop();
    messageController.dispose();
    messageFocus.dispose();
    scrollController.dispose();
    drawer.dispose();
    super.onClose();
  }
}
